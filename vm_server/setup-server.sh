#!/usr/bin/env sh

#  ██████╗  ██████╗   ██╗  ██╗    ██╗      █████╗  ██████╗
#  ██╔══██╗ ██╔═══██╗ ╚██╗██╔╝    ██║     ██╔══██╗ ██╔══██╗
#  ██████╔╝ ██║   ██║  ╚███╔╝     ██║     ███████║ ██████╔╝
#  ██╔══██╗ ██║   ██║  ██╔██╗     ██║     ██╔══██║ ██╔══██╗
#  ██████╔╝ ╚██████╔╝ ██╔╝ ██╗    ██████╗ ██║  ██║ ██████╔╝
#  ╚═════╝   ╚═════╝  ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝

#---------------------------------------------------------
# init
#---------------------------------------------------------

cust_log() {
    local message="$1"
    local tag="box_lab"
    printf "\e[1;32m[*]\e[0m %s\n" "$message"
    logger -t "$tag" "$message"
}
# sudo journalctl -t box_lab -f

MYSCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
cd "$MYSCRIPTPATH" || exit 1
head -n 8 "$0"
cust_log "$0 running on $(hostname)";
ls -la --;
sleep 3s;

start_timer() {
    start_time=$(date +%s)
}

start_timer

end_timer() {
    end_time=$(date +%s)
    total_time=$((end_time - start_time))
    hours=$((total_time / 3600))
    minutes=$(( (total_time % 3600) / 60 ))
    seconds=$((total_time % 60))
    cust_log "Script ran for: ${hours}h ${minutes}m ${seconds}s"
}

if [ ! -d /opt/boxlab ]; then
    sudo mkdir -pv /opt/boxlab/config
    sudo chmod -v 700 /opt/boxlab/config
    sudo chmod -v 775 /opt/boxlab
    sudo chown vagrant:vagrant -v -R /opt/boxlab
fi

mysshkeyloc="/home/$USER/.ssh/id_rsa"
if [ ! -f $mysshkeyloc ]; then
    ssh-keygen -t rsa -P "" -q -C "devops_automation" -f $mysshkeyloc;
fi

#---------------------------------------------------------
# Linux packages
#---------------------------------------------------------

cust_log "install packages"
sudo dnf install -y -q tmux socat telnet vim nmap whois expect iotop python3.11-pip tcpdump || { echo 'ERROR installing dnf package'; exit 1; }
sudo dnf groupinstall -y -q "Development Tools"

cust_log "install EPEL packages"
sudo dnf -y -q install epel-release
sudo dnf -y -q install htop jq pwgen inotify-tools || { echo 'ERROR installing epel package'; exit 1; }

#---------------------------------------------------------
# Docker
#---------------------------------------------------------

if [ ! -f /etc/yum.repos.d/docker-ce.repo ]; then
    cust_log "install docker"
    cd "$MYSCRIPTPATH" || exit 1
    sudo dnf config-manager --add-repo src/docker-ce.repo
    sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin || { echo 'ERROR installing docker'; exit 1; }
    sudo systemctl --now enable docker
    sudo usermod -a -G docker "$USER"
    sudo docker ps || { echo 'error doing docker ps'; exit 1; }
    cust_log "installed Docker"
else
    cust_log "docker setup already"
fi

#---------------------------------------------------------
# container: Gitlab
#---------------------------------------------------------

cd gitlab || exit 1
if [ -f docker-compose.yml ]; then
    cust_log "start Gitlab container setup"
    sudo docker compose up -d
else
    cust_log "error missing compose file";
    exit 1;
fi

while true; do
    status=$(sudo docker inspect --format='{{.State.Health.Status}}' "gitlab-gitlab-1")
    if [ "$status" = "healthy" ]; then
        cust_log "Container in healthy state";
        break
    else
        cust_log "Container is $status. Waiting for it to become healthy...";
        sleep 25;
    fi
done
sudo docker ps
sleep 5;

if [ ! -f /opt/boxlab/config/initial_root_password ]; then
    cust_log "get GL root password"
    sudo docker exec -it gitlab-gitlab-1 grep "Password:" /etc/gitlab/initial_root_password | tr -d 'Password: ' > /opt/boxlab/config/initial_root_password
    chmod 600 -v /opt/boxlab/config/initial_root_password
    # Stop new user accounts in Gitlab:
    sudo docker exec -it gitlab-gitlab-1 gitlab-rails runner 'ApplicationSetting.last.update(signup_enabled: false)'
fi

# make deploy key for PE
if [ ! -f /opt/boxlab/config/pekey001.ed25519 ]; then ssh-keygen -t ed25519 -P "" -q -C "PuppetEnterprise" -f /opt/boxlab/config/pekey001.ed25519; fi

if [ ! -f /opt/boxlab/config/gitlab_token.txt ]; then
    cust_log "set a PAT for root then use it for setup script"
    myrootpatgl="glpat-$(pwgen -n1 20)"
    echo $myrootpatgl > /opt/boxlab/config/gitlab_token.txt
    chmod 600 -v /opt/boxlab/config/gitlab_token.txt
    sudo docker exec -it gitlab-gitlab-1 gitlab-rails runner "token = User.find_by_username('root').personal_access_tokens.create(scopes: ['api', 'write_repository', 'sudo', 'admin_mode', 'create_runner'], name: 'Devops Automation setup', expires_at: 365.days.from_now); token.set_token('$(cat /opt/boxlab/config/gitlab_token.txt)'); token.save!" || { echo "error setting root token"; exit 1; }
fi

if [ ! -f /opt/boxlab/config/gitlab.txt ]; then
    cust_log "do gitlab conf"
    pip3.11 install python-gitlab==4.1.1 || { echo 'error pip install gitlab'; exit 1; }
    cd "$MYSCRIPTPATH" || exit 1
    python3.11 setup-gitlab.py --url http://127.0.0.1:9980 --token "$(cat /opt/boxlab/config/gitlab_token.txt)" || { echo "setup-gl.py error"; exit 1; }
    touch /opt/boxlab/config/gitlab.txt
fi

if [ ! -f ~/.gitconfig ]; then
    cust_log "do git config"
    git config --global user.name "vagrant"
    git config --global user.email "vagrant@localhost"
fi

if [ ! -f /home/vagrant/.ssh/config ]; then
    cust_log "write ssh config"
cat << EOF > /home/vagrant/.ssh/config
# ssh config
Host gitlab.internal
    User git
    Port 9922
    StrictHostKeyChecking no
EOF
    echo "127.0.0.1    gitlab.internal" | sudo tee -a /etc/hosts
fi

# add puppet control repo code to git server
if [ ! -d /home/vagrant/controlrepo ]; then
    cust_log "clone control repo"
    eval $(ssh-add)
    ssh-add ~/.ssh/id_rsa
    cd ~
    git clone ssh://git@gitlab.internal:9922/coders/controlrepo.git
    cd controlrepo || { echo 'error cloning control repo'; exit 1; }
    git switch --orphan production
    git commit --allow-empty -m "Initial commit by automation"
    git push -u origin production
    git branch -a
    rsync -av /vagrant/controlrepo/* .
    git add -- *
    git add .gitignore
    git commit -m "control repo import"
    git push --set-upstream origin production
    cust_log "git control repo setup done"
fi

#---------------------------------------------------------
# Puppet Enterprise
#---------------------------------------------------------

# extract installer
if [ ! -f /opt/boxlab/puppet-enterprise-2023.5.0-el-9-x86_64/puppet-enterprise-installer ]; then
    cust_log "extract puppet"
    cd "$MYSCRIPTPATH" || exit 1
    gpg --import src/puppet-gpg-signing-key-20250406.pub
    gpg --verify src/puppet-enterprise-2023.5.0-el-9-x86_64.tar.gz.asc || exit 1
    tar -xf src/puppet-enterprise-2023.5.0-el-9-x86_64.tar.gz -C /opt/boxlab/ || exit 1
else
    cust_log "puppet installer already extracted"
fi

# generate puppet config (HOCON format)
if [ ! -f /opt/boxlab/config/pe.conf ]; then
    cust_log "cust pe.conf"
    cd "$MYSCRIPTPATH" || exit 1
    if [ ! -f pe.conf ]; then { cust_log "ERROR missing pe.conf" && exit 1; } fi
    cp -v pe.conf /opt/boxlab/config/pe.conf
    # get r10k_known_hosts value
    sshd_prints=$(python3.11 pe-ssh-git-conf.py --port 9922 --host gitlab.internal)
    echo -e "\n$sshd_prints" | tee -a /opt/boxlab/config/pe.conf
    # puppet admin pw
    pe_pw=$(pwgen 30 1)
    echo -e "\"console_admin_password\": \"$pe_pw\"" | tee -a /opt/boxlab/config/pe.conf
fi

if [ ! -f /opt/boxlab/config/pesetup.txt ]; then
    # copy ssh deploy key
    sudo mkdir -pv /etc/puppetlabs/puppetserver/ssh/
    sudo cp -v /opt/boxlab/config/pekey001.ed25519 /etc/puppetlabs/puppetserver/ssh/
    # Install PE
    if [ ! -f /opt/boxlab/config/pe.conf ]; then { cust_log "ERROR missing custom pe.conf" && exit 1; } fi
    cust_log "run puppet installer"
    sudo DISABLE_ANALYTICS=1 /opt/boxlab/puppet-enterprise-2023.5.0-el-9-x86_64/puppet-enterprise-installer -c /opt/boxlab/config/pe.conf | tee -a /opt/boxlab/pe-setup.log || { cust_log 'ERROR PE installer failed'; exit 1; }
    cust_log "puppet installed"
    # run agent
    for i in {1..2}; do sudo /usr/local/bin/puppet agent -t; done
    cust_log "puppet agent ran twice"
    sudo /usr/local/bin/puppet infrastructure configure || { echo 'error with puppet infra'; exit 1; }
    touch /opt/boxlab/config/pesetup.txt
else
    cust_log "PE alredy running"
fi

if [ ! -f /opt/boxlab/config/eyaml.log ]; then
    cust_log "installing eyaml"
    sudo /opt/puppetlabs/bin/puppetserver gem install hiera-eyaml >> /opt/boxlab/config/eyaml.log || { echo 'failed to install eyaml'; exit 1; }
else
    cust_log "eyaml already installed"
fi

sudo /usr/local/bin/puppet infrastructure status

if [ ! -f /home/vagrant/.puppetlabs/token ]; then
    cust_log "setup admin token"
    pupadminpw=$(cat /opt/boxlab/config/pe.conf | grep console_admin_password | awk '{print $2}' | tr -d '"')
    echo "$pupadminpw" | puppet access login --username admin --lifetime 1y; 
fi

cust_log "install support_tasks module"
if [ ! -d .puppetlabs/etc/code/modules/support_tasks ]; then /usr/local/bin/puppet module install puppetlabs-support_tasks; fi

cust_log "sync control repo code from git"
/opt/puppetlabs/bin/puppet-code deploy --all --wait

cust_log "apply puppet code to prod nodes"
/usr/local/bin/puppet job run --query 'nodes { catalog_environment = "production" }'

#---------------------------------------------------------
# done
#---------------------------------------------------------

end_timer