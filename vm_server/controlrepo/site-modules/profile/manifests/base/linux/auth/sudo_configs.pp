#
# sudo configuration for linux system.
#
# todo: fix error when duplicate data found in hiera
#
class profile::base::linux::auth::sudo_configs (
  Boolean $sudo_info_purge = lookup('profile::base::linux::auth::purge_unmanaged_sudo', Boolean, first, false),
  String $sudo_package_state = 'installed',
  Boolean $sudo_info_purge_noop = false,
  # Lookup the data from Hiera using a deep merge strategy
  Array $auth_sudoers = lookup('profile::base::linux::auth::sudoers', Array, unique, []),
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

  # Iterate over each entry in the auth_sudoers array
  $auth_sudoers.each |$entry| {
    # Check that each entry is a hash (not an integer or other type)
    if $entry.is_a(Hash) {
      # Iterate over each key-value pair in the hash
      $entry.each |$key, $value| {
        # Create a file in /etc/sudoers.d/ for each key
        file { "/etc/sudoers.d/${key}":
          ensure  => 'file',
          content => "${value}\n",
          owner   => 'root',
          group   => 'root',
          mode    => '0440',
        }
      }
    }
  }

  file { '/etc/sudoers':
    ensure       => 'present',
    validate_cmd => '/sbin/visudo -cf %',
    audit        => all,
  }

}
