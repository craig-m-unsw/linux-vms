# sudo_configs.pp
#
# write content to /etc/sudoers.d/<entry>
#
class profile::base::linux::auth::sudo_configs (
  Boolean $sudo_info_purge      = lookup('profile::base::linux::auth::purge_unmanaged_sudo', Boolean, first, false),
  String  $sudo_package_state   = 'installed',
  Boolean $sudo_info_purge_noop = lookup('profile::base::linux::auth::purge_unmanaged_sudo_noop', { 'default_value' => false }),
  #Boolean $sudo_info_purge_noop = false,
  # lookup all info
  Hash    $sudoers_data         = lookup('profile::base::linux::auth::sudo_configs', Hash, 'deep', {}),
) {

  package { 'sudo':
    ensure => $sudo_package_state,
  }

  # delete non-puppet files from here?
  file { '/etc/sudoers.d/':
    ensure  => 'directory',
    purge   => $sudo_info_purge,
    noop    => $sudo_info_purge_noop,
    recurse => true,
  }

  $sudoers_data.each |$key, $value| {
    file { "/etc/sudoers.d/${key}":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0440',
      content => inline_template($value['content']),
    }
  }

  file { '/etc/sudoers':
    ensure       => 'present',
    validate_cmd => '/sbin/visudo -cf %',
    audit        => all,
  }

}
