Vagrant.require_version ">= 2.4.0"

require 'yaml'
if File.exist?('servers_cust.yaml')
    servers = YAML.load_file(File.join(File.dirname(__FILE__), 'vms_cust.yaml'))
else
    servers = YAML.load_file(File.join(File.dirname(__FILE__), 'vms.yaml'))
end

Vagrant.configure("2") do |config|
    config.ssh.keep_alive = true
    config.ssh.compression = false
    config.ssh.forward_agent = false
    config.ssh.insert_key = true
    config.vm.box_check_update = false

    servers.each do |machine|
        next if machine.has_key?('disable') && machine['disable'] == true
        config.vm.define machine["name"] do |node|

            node.vm.box = machine["box"]
            node.vm.hostname = machine["hostname"]
            config.vbguest.auto_update = false

            if machine.has_key? 'ip'
                node.vm.network "private_network", ip: machine["ip"]
            end

            node.vm.provider "virtualbox" do |vb|
                vb.memory = machine["ram"]
                vb.cpus = machine["cpu"]
                vb.customize ["modifyvm", :id, "--vram", "128"]
                vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
            end

            if machine.has_key? 'fshare'
                node.vm.synced_folder machine["fshare"], '/vagrant', type: "rsync", disabled: false
            else
                node.vm.synced_folder './no', '/vagrant', type: "rsync", disabled: true
            end

        end
    end

    config.trigger.after [:up, :resume, :reload] do |t|
        t.info = "running inlinescript_post"
        t.run_remote = { inline: $inlinescript_post, :privileged => false }
    end

end

$inlinescript_post = <<-SCRIPT
echo '-----------------------';
uname -a;
uptime;
echo '-----------------------';
SCRIPT

# vim: set filetype=ruby: