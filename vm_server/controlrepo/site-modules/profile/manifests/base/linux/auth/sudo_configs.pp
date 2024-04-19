#
# sudo configuration for linux system.
#
#
# example hiera data to supply class below
#
# profile::base::linux::auth::purge_unmanaged_sudo: true
# profile::base::linux::auth::sudoers:
#   - wheelgroup:
#       content: |
#         %wheel ALL=(ALL) ALL"
#   - vagrant:
#       content: |
#         Defaults:vagrant !requiretty
#         %vagrant ALL=(ALL) NOPASSWD: ALL
#
#
class profile::base::linux::auth::sudo_configs (
  Boolean $sudo_info_purge = lookup('profile::base::linux::auth::purge_unmanaged_sudo', Boolean, first, false),
  Array $sudoers_data_array = lookup('profile::base::linux::auth::sudoers', Array, unique, []),
  String $sudo_package_state = 'installed',
) {

  package { 'sudo':
    ensure => $sudo_package_state,
  }

  file { '/etc/sudoers.d/':
    ensure  => 'directory',
    purge   => $sudo_info_purge,
    recurse => true,
  }

  $sudoers_data_array.each |$sudo_entry| {
    if $sudo_entry.keys.size != 1 {
      fail("Invalid sudoers entry: ${sudo_entry}. Each entry should contain only one key-value pair.")
    }

    $user = $sudo_entry.keys[0]
    $content = $sudo_entry[$user]['content']

    $sudoers_file = "/etc/sudoers.d/${user}"

    file { $sudoers_file:
      ensure  => 'file',
      content => "# Puppet managed\n${content}\n",
      mode    => '0440',
    }
  }

  file { '/etc/sudoers':
    ensure       => 'present',
    validate_cmd => '/sbin/visudo -cf %',
    audit        => all,
  }

}
