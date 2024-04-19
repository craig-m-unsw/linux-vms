# root account settings
#
# todo: lookup root password and lock if no entry found
#
class profile::base::linux::auth::root_auth (
  # remove non-puppet files under /root/.ssh/ ?
  Boolean $root_ssh_purge_file = true,
) {

  # lock root user account, read "man shadow" for details
  # access via regular user with sudo
  user { 'root':
    ensure   => present,
    password => '!',
  }

  # home dir folders
  $root_homedir_folder = ['/root/', '/root/.config/', '/root/temp/', '/root/scripts/']
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

  # remove non-puppet files
  file { '/root/.ssh/':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    purge   => $root_ssh_purge_file,
    recurse => true,
  }

  # monitor for changes
  $root_file_mon = ['/root/.bashrc', '/root/.profile',]
  file {
    default:
      audit => all,
    ;
    $root_file_mon:
    ;
  }

}
