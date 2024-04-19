#
# AppArmor Mandatory Access Control (MAC)
# https://gitlab.com/apparmor/apparmor/-/wikis/Documentation
#
#
class profile::base::linux::distro::debian_based::apparmor (
  String  $apparmor_package = 'installed',
  String  $apparmor_ensure  = 'running',
  Boolean $apparmor_enable  = true,
) {

  # we don't use apparmor on non-debian Linux
  if $facts['os']['family'] != 'Debian' { fail('Unsupported OS') }

  package { ['apparmor-profiles', 'apparmor-utils']:
    ensure  => $apparmor_package,
  }

  service { 'apparmor':
    ensure  => $apparmor_ensure,
    enable  => $apparmor_enable,
    require => [
      Package['apparmor-profiles'],
    ],
  }

}
