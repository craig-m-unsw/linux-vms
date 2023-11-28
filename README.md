# Linux box admin

Use the [chef](https://www.chef.io/products/chef-infra) bento [project](https://github.com/chef/bento) to build the [Vagrant](https://www.vagrantup.com/) [boxes](https://app.vagrantup.com/bento).

Tested November 2023 on:

* Ubuntu 22.04.3 LTS (Jammy Jellyfish)
* Virtual Box 7.0.12 r159484 (Qt5.15.3)
* Packer 1.9.4
* Vagrant 2.4.0

## build

Build VM box images. Some of the iso url might need updating, the Debian url changed from 'release' to 'archive'.

```shell
./make-bento-boxes.sh
```

Download installers:

```shell
python3 vm_server/get_files.py --download_folder=vm_server/src/
```

Start up virtual machines:

```shell
vagrant validate
vagrant up
vagrant ssh puppet -- -L 4343:127.0.0.1:443 -L 9980:127.0.0.1:9980
```

the port forwarding in Vagrant can be temperamental so I use a tunnel.

## use

setup FQDN for Puppet:

```shell
sudo hostnamectl set-hostname puppet.mylocal
echo '127.0.1.1     puppet.mylocal puppet.local' | sudo tee -a /etc/hosts
```

Setup Gitlab + PE:

```shell
/vagrant/setup-server.sh
```

Login to [Puppet](https://localhost:4343/auth/login?redirect=/) and [Gitlab](http://localhost:9980/users/sign_in) web console, the passwords can be found in `/opt/boxlab/config/`

