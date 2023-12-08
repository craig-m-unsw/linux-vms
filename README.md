# Linux box admin

Use the [chef](https://www.chef.io/products/chef-infra) bento [project](https://github.com/chef/bento) to build the [Vagrant](https://www.vagrantup.com/) [boxes](https://app.vagrantup.com/bento), then run Puppet Enterprise to configure them.

## build

Build VM box images. Some of the iso url might need updating, the Debian url changed from 'release' to 'archive'.

```shell
./make-bento-boxes.sh
```

Download everything we need (eg Puppet Enterprise):

```shell
python3 vm_server/get_files.py --download_folder=vm_server/src/
```

Start up virtual machines:

```shell
vagrant validate
vagrant up
vagrant ssh-config puppet >> ~/.ssh/config
vagrant ssh puppet -- -L 4343:127.0.0.1:443 -L 9980:127.0.0.1:9980
```

the port forwarding in Vagrant can be temperamental so I use a tunnel.

## use

Setup Gitlab + PE:

```shell
/vagrant/setup-server.sh
```

Login to [Puppet](https://localhost:4343/auth/login?redirect=/) and [Gitlab](http://localhost:9980/users/sign_in) web console, the passwords can be found in `/opt/boxlab/config/`

Use [VSCode remote](https://code.visualstudio.com/docs/remote/remote-overview) to connect into Puppet vm and open `~/controlrepo`

### nodes

Put nodes under puppet control:

```shell
vagrant ssh rockylinux9
echo '192.168.60.13     puppet.mylocal puppet.local' | sudo tee -a /etc/hosts
curl --insecure https://puppet.mylocal:8140/packages/current/install.bash | sudo bash -s extension_requests:pp_role=node
```
