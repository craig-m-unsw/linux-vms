class profile::base::dirs {

    file {
        default:
            ensure => 'directory',
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
        ;
        ['/var/log/opt/', '/etc/opt/boxlab/', '/usr/local/share/keyrings/']:
        ;
        ['/opt/boxlab/puppet/',]:
            mode => '0700',
        ;
    }

}
