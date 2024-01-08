#!/usr/bin/env bash

echo 'Make some bento boxes';
set -x

if [ -d "./bento" ]; then
    printf "have bento src";
else
    git clone https://github.com/chef/bento.git;
    printf "cloned bento src";
fi

cd bento/ || { echo 'error no src'; exit 1; }
git checkout v3.2.0;

packer init -upgrade ./packer_templates;

declare -a templates=(
  "os_pkrvars/centos/centos-7-x86_64.pkrvars.hcl"
  "os_pkrvars/centos/centos-stream-8-x86_64.pkrvars.hcl"
  "os_pkrvars/centos/centos-stream-9-x86_64.pkrvars.hcl"
  "os_pkrvars/ubuntu/ubuntu-22.04-x86_64.pkrvars.hcl"
  "os_pkrvars/ubuntu/ubuntu-20.04-x86_64.pkrvars.hcl"
  "os_pkrvars/fedora/fedora-38-x86_64.pkrvars.hcl"
  "os_pkrvars/fedora/fedora-37-x86_64.pkrvars.hcl"
  "os_pkrvars/rockylinux/rockylinux-9-x86_64.pkrvars.hcl"
  "os_pkrvars/rockylinux/rockylinux-8-x86_64.pkrvars.hcl"
)

for template in "${templates[@]}"; do
    packer build -only=virtualbox-iso.vm -var-file="$template" ./packer_templates;
done

echo 'done';
