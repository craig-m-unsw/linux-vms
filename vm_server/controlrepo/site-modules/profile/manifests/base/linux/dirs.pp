class profile::base::linux::dirs {

  file {
    default:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    ;
    ['/var/log/opt/', '/etc/opt/cluster/', '/usr/local/share/keyrings/']:
    ;
    ['/opt/cluster/',]:
      mode => '0700',
    ;
  }

}
