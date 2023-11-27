#!/usr/bin/env python3

'''
Download files and check sha sum
'''

import os
import sys
import hashlib
import urllib.request
import argparse
from pathlib import Path

file_info = [
    { "url": "https://downloads.puppet.com/puppet-gpg-signing-key-20250406.pub", "sha256": "4d5a9c73f97235eebe8c69f728aa2efcc8e1ee02282f972efdbbbd3a430be454" },
    { "url": "https://pm.puppetlabs.com/puppet-enterprise/2023.5.0/puppet-enterprise-2023.5.0-el-9-x86_64.tar.gz", "sha256": "13d51a9b01fbe1ed41174df8d0fbd4dde6d7946375f3326db839af8080d1603b" },
    { "url": "https://pm.puppetlabs.com/puppet-enterprise/2023.5.0/puppet-enterprise-2023.5.0-el-9-x86_64.tar.gz.asc", "sha256": "fda87b4877817819f45109e652f417be99e0fd5bd009199c457bbcff69889fa9" },
    { "url": "https://github.com/puppetlabs/control-repo/archive/refs/tags/1.1.0.tar.gz", "sha256": "895bb2caea754b06709ab701fab2ae2b56268c6b22576ce6ffe9703c556f52b8" },
    { "url": "https://download.docker.com/linux/centos/docker-ce.repo", "sha256": "8ab5599eef0afcac10cbd3e8670873efee20fcceb5fb3526a62edeade603cec7" },
]

def check_permissions(folder):
    if os.geteuid() == 0:
        print("Error: Running as root is not allowed.")
        sys.exit(1)

def download_file(url, filename):
    try:
        print(f"Downloading: {url} -> {filename}")
        urllib.request.urlretrieve(url, filename)
    except Exception as e:
        print(f"Failed to download {url}: {e}")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description='Download files from specified URLs.')
    parser.add_argument('--download_folder', required=True, help='Folder to download files into')
    args = parser.parse_args()

    download_folder = args.download_folder

    check_permissions(download_folder)

    if not os.path.exists(download_folder):
        os.makedirs(download_folder)

    for info in file_info:
        url = info["url"]
        expected_sha256 = info["sha256"]
        filename = os.path.join(download_folder, url.split('/')[-1])

        if os.path.exists(filename):
            print(f"File '{filename}' already exists. Skipping download.")
        else:
            download_file(url, filename)

        sha256 = hashlib.sha256()
        with open(filename, "rb") as f:
            while True:
                # Read file in 64KB chunks
                data = f.read(65536)
                if not data:
                    break
                sha256.update(data)

        actual_sha256 = sha256.hexdigest()
        if actual_sha256 == expected_sha256:
            print(f"Verified: {filename}")
        else:
            print(f"Checksum mismatch for {filename}. Expected: {expected_sha256}, Actual: {actual_sha256}")

    print("Finished get_files.py")

if __name__ == "__main__":
    main()
