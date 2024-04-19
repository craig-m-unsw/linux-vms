#
# ssh server
#
class profile::base::linux::ssh (
  String  $ssh_server_package = 'present',
  String  $ssh_server_ensure  = 'running',
  Boolean $ssh_server_enable  = true,
) {

  # SSH package
  $ssh_server_package_name = $facts['os']['name'] ? {
    default => 'openssh-server',
  }
  package { $ssh_server_package_name:
    ensure => $ssh_server_package,
    alias  => 'ssh_server',
  }

  # SSH Service name
  $ssh_server_daemon = $facts['os']['name'] ? {
    default => 'sshd',
  }
  service { $ssh_server_daemon:
    ensure  => $ssh_server_ensure,
    enable  => $ssh_server_enable,
    require => Package[$ssh_server_package_name],
  }

  # monitor config
  file { '/etc/ssh/sshd_config':
    audit        => all,
    notify       => Service[$ssh_server_daemon],
    require      => Package[$ssh_server_package_name],
    validate_cmd => '/usr/sbin/sshd -f /etc/ssh/sshd_config -t',
  }

  file { '/etc/ssh/ssh_config.d/':
    ensure  => 'directory',
    purge   => true,
    noop    => true,
    recurse => true,
  }

  file { '/etc/ssh/sshd_config.d/':
    ensure  => 'directory',
    purge   => true,
    noop    => true,
    recurse => true,
  }

}
