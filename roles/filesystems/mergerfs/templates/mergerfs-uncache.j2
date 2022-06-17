#!/usr/bin/python3
import argparse
import shutil
import subprocess
import syslog
import time
from pathlib import Path


if __name__ == "__main__":
    """
    Uncaching utility. This scripts assumes that you have a cache-like
    mount point, for which you want to preserve a certain amount of free
    space by moving heavy/rarely-accessed files to a slower mount point.

    The script, in its simplest form, can be run as:

    ::

        $ ./mergerfs-uncache.py -s /mnt/cache -d /mnt/slow -t 75

    In this way least accessed files will be moved one after the other
    until the percentage of used capacity will be less than the target.
    Other options are also available. Please consider this is a work in
    progress.
    """

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-s",
        "--source",
        dest="source",
        type=Path,
        help="Source path (i.e. cache pool root path.",
    )
    parser.add_argument(
        "-d",
        "--destination",
        dest="destination",
        type=Path,
        help="Destination path (i.e. slow pool root path.",
    )
    parser.add_argument(
        "--num-files",
        dest="num_files",
        default=-1,
        type=int,
        help="Maximum number of files moved away from cache.",
    )
    parser.add_argument(
        "--time-limit",
        dest="time_limit",
        default=-1,
        type=int,
        help="Time limit for the whole process (in seconds). Once reached program exits.",
    )
    parser.add_argument(
        "-t",
        "--target",
        dest="target",
        type=float,
        help="Desired max cache usage, in percentage (e.g. 70).",
    )
    parser.add_argument(
        "-v", "--verbose", help="Increase output verbosity.", action="store_true"
    )
    args = parser.parse_args()

    # Some general checks
    cache_path: Path = args.source
    if not cache_path.is_dir():
        raise NotADirectoryError(f"{cache_path} is not a valid directory.")
    slow_path: Path = args.destination
    if not slow_path.is_dir():
        raise NotADirectoryError(f"{slow_path} is not a valid directory.")

    last_id = args.num_files
    time_limit = args.time_limit

    target = float(args.target)
    if target <= 1 or target >= 100:
        raise ValueError(
            f"Target value is in percentage, i.e. in the range of (0, 100). Found {target} instead."
        )

    cache_stats = shutil.disk_usage(cache_path)

    usage_percentage = 100 * cache_stats.used / cache_stats.total
    syslog.syslog(
        syslog.LOG_INFO,
        f"Uncaching from {cache_path} ({usage_percentage:.2f}% used) to {slow_path}.",
    )
    if usage_percentage <= target:
        syslog.syslog(
            syslog.LOG_INFO,
            f"Target of {target}% of used capacity already reached. Exiting.",
        )
        exit(0)

    syslog.syslog(syslog.LOG_INFO, "Computing candidates...")
    candidates = sorted(
        [(c, c.stat()) for c in cache_path.glob("**/*") if c.is_file()],
        key=lambda p: p[1].st_atime,
    )

    t_start = time.monotonic()
    syslog.syslog(syslog.LOG_INFO, "Processing candidates...")
    cache_used = cache_stats.used
    for c_id, (c_path, c_stat) in enumerate(candidates):
        syslog.syslog(syslog.LOG_DEBUG, f"{c_path}")

        if not c_path.exists():
            # Since rsync moves also other hard links it might be that
            # some files are not existing anymore. However, invoking rsync
            # for each file (instead of directories) does not preserve
            # hard links.
            syslog.syslog(syslog.LOG_WARNING, f"{c_path} does not exist.")
            continue

        # Rsync options
        # -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
        # -x, --one-file-system       don't cross filesystem boundaries
        # -q, --quiet                 suppress non-error messages
        # -H, --hard-links            preserve hard links
        # -A, --acls                  preserve ACLs (implies --perms)
        # -X, --xattrs                preserve extended attributes
        # -W, --whole-file            copy files whole (without delta-xfer algorithm)
        # -E, --executability         preserve the file's executability
        # -S, --sparse                turn sequences of nulls into sparse blocks
        # -R, --relative              use relative path names
        # --preallocate               allocate dest files before writing them
        # --remove-source-files       sender removes synchronized files (non-dirs)
        subprocess.call(
            [
                "rsync",
                "-axqHAXWESR",
                "--preallocate",
                "--remove-source-files",
                f"{cache_path}/./{c_path.relative_to(cache_path)}",
                f"{slow_path}/",
            ]
        )
        cache_used -= c_stat.st_size

        # Evaluate early breaking conditions
        if last_id >= 0 and c_id >= last_id - 1:
            syslog.syslog(
                syslog.LOG_INFO, f"Maximum number of moved files reached ({last_id})."
            )
            break
        if time_limit >= 0 and time.monotonic() - t_start > time_limit:
            syslog.syslog(
                syslog.LOG_INFO, f"Time limit reached ({time_limit} seconds)."
            )
            break
        if (100 * cache_used / cache_stats.total) <= target:
            syslog.syslog(
                syslog.LOG_INFO, f"Target of maximum used capacity reached ({target})."
            )
            break

    cache_stats = shutil.disk_usage(cache_path)
    usage_percentage = 100 * cache_stats.used / cache_stats.total
    syslog.syslog(
        syslog.LOG_INFO,
        f"Process completed in {round(time.monotonic() - t_start)} seconds. Current usage percentage is {usage_percentage:.2f}%.",
    )
