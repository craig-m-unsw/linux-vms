# root account settings
#
#
class profile::base::linux::auth::root_auth (
  # remove non-puppet files under /root/.ssh/ ?
  Boolean $root_ssh_purge_file      = true,
  Boolean $root_ssh_purge_file_noop = false,
  # make these folders
  Array $root_homedir_folder = ['/root/', '/root/.config/', '/root/temp/', '/root/scripts/'],
  # monitor these root files
  Array $root_file_mon = ['/root/.bashrc', '/root/.profile',],
) {

  # lock root user account, read "man shadow" for details
  # access via regular user with sudo
  user { 'root':
    ensure   => present,
    password => '!',
  }

  # home dir folders
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

  # root ssh files
  file { '/root/.ssh/':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    recurse => true,
    purge   => $root_ssh_purge_file,
    noop    => $root_ssh_purge_file_noop,
  }

  file {
    default:
      audit => all,
    ;
    $root_file_mon:
    ;
  }

}
