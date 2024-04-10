#
# an array of folders we want on all Linux systems
#
class profile::base::linux::dirs (
  Array $linux_base_dirs_pub = ['/var/log/opt/', '/etc/opt/cluster/', '/usr/local/share/keyrings/'],
  Array $linux_base_dirs_priv = ['/opt/cluster/'],
) {

  file {
    default:
      ensure => 'directory',
      owner  => 'root',
      group  => 'root',
    ;
    $linux_base_dirs_pub:
      mode => '0755',
    ;
    $linux_base_dirs_priv:
      mode => '0700',
    ;
  }

}
