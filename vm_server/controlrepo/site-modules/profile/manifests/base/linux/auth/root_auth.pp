class profile::base::linux::auth::root_auth (
    $root_homedir_folder = ['/root/', '/root/.ssh/', '/root/.config/', '/root/temp/', '/root/scripts/']
) { 

    # lock root user account, read "man shadow" for details
    # access via regular user with sudo

    user { 'root':
        ensure   => present,
        password => '!',
    }

    file {
        default:
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
        mode   => '0700',
        ;
        $root_homedir_folder:
        ;
    }

}