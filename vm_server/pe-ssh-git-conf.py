#!/usr/bin/env python3

'''
set sshd fingerprints of git server for PE config.
https://www.puppet.com/docs/pe/2023.5/code_mgr_config
'''

import subprocess
import argparse
import re
import json

def get_ssh_keys(port, host):
    try:
        command = ["ssh-keyscan", "-p", str(port), host]
        result = subprocess.run(command, capture_output=True, text=True, check=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running ssh-keyscan: {e}")
        return None

def process_ssh_keys(ssh_keys):
    keys = []
    pattern = re.compile(r'\[([^\]]+)\]\:(\d+)\s+([^\s]+)\s+([^\n]+)')

    matches = pattern.findall(ssh_keys)
    for match in matches:
        name, port, key_type, key = match
        keys.append({
            "name": name,
            "type": key_type,
            "key": key
        })

    return keys

def main():
    parser = argparse.ArgumentParser(description='Process SSH keys from a given host and port.')
    parser.add_argument('--port', type=int, required=True, help='Port for SSH connection')
    parser.add_argument('--host', required=True, help='Host for SSH connection')

    args = parser.parse_args()
    ssh_keys = get_ssh_keys(args.port, args.host)

    if ssh_keys:
        processed_keys = process_ssh_keys(ssh_keys)
        print('"puppet_enterprise::profile::master::r10k_known_hosts": ' + json.dumps(processed_keys, indent=None))

if __name__ == "__main__":
    main()