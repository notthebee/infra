#!/usr/bin/env bash

# initialise arrays for incoming ports
incoming_ports_ext_array=()
incoming_ports_lan_array=()

# append incoming ports for applications to arrays
if [[ "${APPLICATION}" == "rtorrent" ]]; then
	incoming_ports_ext_array+=(9080 9443)
	incoming_ports_lan_array+=(5000)
elif [[ "${APPLICATION}" == "qbittorrent" ]]; then
	incoming_ports_ext_array+=(${WEBUI_PORT})
elif [[ "${APPLICATION}" == "sabnzbd" ]]; then
	incoming_ports_ext_array+=(8080 8090)
elif [[ "${APPLICATION}" == "deluge" ]]; then
	incoming_ports_ext_array+=(8112)
	incoming_ports_lan_array+=(58846)
fi

# if microsocks enabled (privoxyvpn only) then add port for microsocks to incoming ports lan array
if [[ "${ENABLE_SOCKS}" == "yes" ]]; then
	incoming_ports_lan_array+=(9118)
fi

# if privoxy enabled then add port for privoxy to  incoming ports lan array
if [[ "${ENABLE_PRIVOXY}" == "yes" ]]; then
	incoming_ports_lan_array+=(8118)
fi

# if vpn input ports specified then add to incoming ports external array
if [[ ! -z "${VPN_INPUT_PORTS}" ]]; then

	# split comma separated string into array from VPN_INPUT_PORTS env variable
	IFS=',' read -ra vpn_input_ports_array <<< "${VPN_INPUT_PORTS}"

	# merge both arrays
	incoming_ports_ext_array=("${incoming_ports_ext_array[@]}" "${vpn_input_ports_array[@]}")

fi

# if vpn output ports specified then add to outbound ports lan array
if [[ ! -z "${VPN_OUTPUT_PORTS}" ]]; then
	# split comma separated string into array from VPN_OUTPUT_PORTS env variable
	IFS=',' read -ra outgoing_ports_lan_array <<< "${VPN_OUTPUT_PORTS}"
fi

# identify docker bridge interface name by looking at defult route
docker_interface=$(ip -4 route ls | grep default | xargs | grep -o -P '[^\s]+$')
if [[ "${DEBUG}" == "true" ]]; then
	echo "[debug] Docker interface defined as ${docker_interface}"
fi

# identify ip for local gateway (eth0)
default_gateway=$(ip route show default | awk '/default/ {print $3}')
echo "[info] Default route for container is ${default_gateway}"

# identify ip for docker bridge interface
docker_ip=$(ifconfig "${docker_interface}" | grep -P -o -m 1 '(?<=inet\s)[^\s]+')
if [[ "${DEBUG}" == "true" ]]; then
	echo "[debug] Docker IP defined as ${docker_ip}"
fi

# identify netmask for docker bridge interface
docker_mask=$(ifconfig "${docker_interface}" | grep -P -o -m 1 '(?<=netmask\s)[^\s]+')
if [[ "${DEBUG}" == "true" ]]; then
	echo "[debug] Docker netmask defined as ${docker_mask}"
fi

# array for both protocols
multi_protocol_array=(tcp udp)

# convert netmask into cidr format
docker_network_cidr=$(ipcalc "${docker_ip}" "${docker_mask}" | grep -P -o -m 1 "(?<=Network:)\s+[^\s]+")
echo "[info] Docker network defined as ${docker_network_cidr}"

# split comma separated string into array from LAN_NETWORK env variable
IFS=',' read -ra lan_network_array <<< "${LAN_NETWORK}"

# split comma separated string into array from VPN_REMOTE_PORT env var
IFS=',' read -ra vpn_remote_port_array <<< "${VPN_REMOTE_PORT}"

# ip route
###

# process lan networks in the array
for lan_network_item in "${lan_network_array[@]}"; do

	# strip whitespace from start and end of lan_network_item
	lan_network_item=$(echo "${lan_network_item}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

	echo "[info] Adding ${lan_network_item} as route via docker ${docker_interface}"
	ip route add "${lan_network_item}" via "${default_gateway}" dev "${docker_interface}"

done

echo "[info] ip route defined as follows..."
echo "--------------------"
ip route s t all
echo "--------------------"

# iptables marks
###

if [[ "${DEBUG}" == "true" ]]; then
	echo "[debug] Modules currently loaded for kernel" ; lsmod
fi

# check we have iptable_mangle, if so setup fwmark
lsmod | grep iptable_mangle
iptable_mangle_exit_code="${?}"

if [[ "${iptable_mangle_exit_code}" == 0 ]]; then

	echo "[info] iptable_mangle support detected, adding fwmark for tables"

	mark=0

	# setup route for application using set-mark to route traffic to lan
	for incoming_ports_ext_item in "${incoming_ports_ext_array[@]}"; do

		mark=$((${mark}+1))
		echo "${incoming_ports_ext_item}    ${incoming_ports_ext_item}_${APPLICATION}" >> '/etc/iproute2/rt_tables'
		ip rule add fwmark "${mark}" table "${incoming_ports_ext_item}_${APPLICATION}"
		ip route add default via "${default_gateway}" table "${incoming_ports_ext_item}_${APPLICATION}"

	done

fi

# input iptable rules
###

# set policy to drop ipv4 for input
iptables -P INPUT DROP

# set policy to drop ipv6 for input
ip6tables -P INPUT DROP 1>&- 2>&-

# accept input to/from docker containers (172.x range is internal dhcp)
iptables -A INPUT -s "${docker_network_cidr}" -d "${docker_network_cidr}" -j ACCEPT

for vpn_remote_ip_item in "${vpn_remote_ip_array[@]}"; do

	# note grep -e is required to indicate no flags follow to prevent -A from being incorrectly picked up
	rule_exists=$(iptables -S | grep -e "-A INPUT -i "${docker_interface}" -s "${vpn_remote_ip_item}" -j ACCEPT")

	if [[ -z "${rule_exists}" ]]; then

		# return rule
		iptables -A INPUT -i "${docker_interface}" -s "${vpn_remote_ip_item}" -j ACCEPT

	fi

done

for incoming_ports_ext_item in "${incoming_ports_ext_array[@]}"; do

	for vpn_remote_protocol_item in "${multi_protocol_array[@]}"; do

		# allows communication from any ip (ext or lan) to containers running in vpn network on specific ports
		iptables -A INPUT -i "${docker_interface}" -p "${vpn_remote_protocol_item}" --dport "${incoming_ports_ext_item}" -j ACCEPT

	done

done

# process lan networks in the array
for lan_network_item in "${lan_network_array[@]}"; do

	# strip whitespace from start and end of lan_network_item
	lan_network_item=$(echo "${lan_network_item}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

	for incoming_ports_lan_item in "${incoming_ports_lan_array[@]}"; do

		# allows communication from lan ip to containers running in vpn network on specific ports
		iptables -A INPUT -i "${docker_interface}" -s "${lan_network_item}" -d "${docker_network_cidr}" -p tcp --dport "${incoming_ports_lan_item}" -j ACCEPT

	done

	for outgoing_ports_lan_item in "${outgoing_ports_lan_array[@]}"; do

		# return rule
		iptables -A INPUT -i "${docker_interface}" -s "${lan_network_item}" -d "${docker_network_cidr}" -p tcp --sport "${outgoing_ports_lan_item}" -j ACCEPT

	done

done

# accept input icmp (ping)
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

# accept input to local loopback
iptables -A INPUT -i lo -j ACCEPT

# accept input to tunnel adapter
iptables -A INPUT -i "${VPN_DEVICE_TYPE}" -j ACCEPT

# forward iptable rules
###

# set policy to drop ipv4 for forward
iptables -P FORWARD DROP

# set policy to drop ipv6 for forward
ip6tables -P FORWARD DROP 1>&- 2>&-

# output iptable rules
###

# set policy to drop ipv4 for output
iptables -P OUTPUT DROP

# set policy to drop ipv6 for output
ip6tables -P OUTPUT DROP 1>&- 2>&-

# accept output to/from docker containers (172.x range is internal dhcp)
iptables -A OUTPUT -s "${docker_network_cidr}" -d "${docker_network_cidr}" -j ACCEPT

# iterate over remote ip address array (from start.sh) and create accept rules
for vpn_remote_ip_item in "${vpn_remote_ip_array[@]}"; do

	# note grep -e is required to indicate no flags follow to prevent -A from being incorrectly picked up
	rule_exists=$(iptables -S | grep -e "-A OUTPUT -o "${docker_interface}" -d "${vpn_remote_ip_item}" -j ACCEPT")

	if [[ -z "${rule_exists}" ]]; then

		# accept output to remote vpn endpoint
		iptables -A OUTPUT -o "${docker_interface}" -d "${vpn_remote_ip_item}" -j ACCEPT

	fi

done

# if iptable mangle is available (kernel module) then use mark
if [[ "${iptable_mangle_exit_code}" == 0 ]]; then

	mark=0

	for incoming_ports_ext_item in "${incoming_ports_ext_array[@]}"; do

		mark=$((${mark}+1))
		# accept output from application - used for external access
		iptables -t mangle -A OUTPUT -p tcp --sport "${incoming_ports_ext_item}" -j MARK --set-mark "${mark}"

	done

fi

for incoming_ports_ext_item in "${incoming_ports_ext_array[@]}"; do

	for vpn_remote_protocol_item in "${multi_protocol_array[@]}"; do

		# return rule
		iptables -A OUTPUT -o "${docker_interface}" -p "${vpn_remote_protocol_item}" --sport "${incoming_ports_ext_item}" -j ACCEPT

	done

done

# process lan networks in the array
for lan_network_item in "${lan_network_array[@]}"; do

	# strip whitespace from start and end of lan_network_item
	lan_network_item=$(echo "${lan_network_item}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

	for incoming_ports_lan_item in "${incoming_ports_lan_array[@]}"; do

		# return rule
		iptables -A OUTPUT -o "${docker_interface}" -s "${docker_network_cidr}" -d "${lan_network_item}" -p tcp --sport "${incoming_ports_lan_item}" -j ACCEPT

	done

	for outgoing_ports_lan_item in "${outgoing_ports_lan_array[@]}"; do

		# allows communication from vpn network to containers running in lan network on specific ports
		iptables -A OUTPUT -o "${docker_interface}" -s "${docker_network_cidr}" -d "${lan_network_item}" -p tcp --dport "${outgoing_ports_lan_item}" -j ACCEPT

	done

done

# accept output for icmp (ping)
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

# accept output from local loopback adapter
iptables -A OUTPUT -o lo -j ACCEPT

# accept output from tunnel adapter
iptables -A OUTPUT -o "${VPN_DEVICE_TYPE}" -j ACCEPT

iptables -A INPUT -s 172.20.0.0/16 -d 172.20.0.0/16 -j ACCEPT
iptables -A OUTPUT -s 172.20.0.0/16 -d 172.20.0.0/16 -j ACCEPT

echo "[info] iptables defined as follows..."
echo "--------------------"
iptables -S 2>&1 | tee /tmp/getiptables
chmod +r /tmp/getiptables
echo "--------------------"
