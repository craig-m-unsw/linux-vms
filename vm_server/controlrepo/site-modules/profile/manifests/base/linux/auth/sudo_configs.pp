#
# lookup a hash of data from hiera
#
class profile::base::linux::auth::sudo_configs (
  $sudo_info       = lookup('profile::base::linux::auth::sudoers', {}),
  $sudo_info_purge = lookup('profile::base::linux::auth::purge_unmanaged_sudo', Boolean, first, false),
) {

  # install sudo (https://www.sudo.ws/)
  package { 'sudo':
    ensure => installed,
  }

  # remove non-puppet files from sudoers.d folder for security
  file { '/etc/sudoers.d/':
    ensure  => 'directory',
    purge   => $sudo_info_purge,
    recurse => true,
  }

  # iterate over sudo information from hiera
  $sudo_info.each |$user, $sudo_line| {
    $sudoers_file_path    = "/etc/sudoers.d/${user}"
    $sudoers_file_content = $sudo_line[content]

    file { $sudoers_file_path:
      ensure  => file,
      content => "${sudoers_file_content}\n",
      mode    => '0440'
    }
  }

  # validate and monitor /etc/sudoers for changes
  file { '/etc/sudoers':
    ensure       => 'present',
    validate_cmd => '/sbin/visudo -cf %',
    audit        => all,
  }

}
