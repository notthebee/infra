# notthebee/infra/cloud-init
A user-data configuration file for an unattended installation of Ubuntu Server 20.04 

## Usage:
Clone the ubuntu-autoinstall-generator repository:
```
git clone https://github.com/covertsh/ubuntu-autoinstall-generator
cd ubuntu-autoinstall-generator
```

Install dependencies (macOS):
```
brew install p7zip gpg xorriso
```

Replace `mkisofs` with `xorriso` (at least until [#19](https://github.com/covertsh/ubuntu-autoinstall-generator/pull/19) is merged)
```
sed -i '' 's/mkisofs -quiet/xorriso -as mkisofs -quiet/g' ubuntu-autoinstall-generator.sh
```

Run the script:
```
bash ubuntu-autoinstall-generator.sh -k -a -u /path/to/this/repo/cloud-init/user-data
```

Use the resulting ISO to install Ubuntu Server 20.04