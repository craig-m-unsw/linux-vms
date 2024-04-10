#
# todo
#
class profile::base::linux::distro::debian_based::apparmor (

) {

  # we don't use apparmor on non-debian Linux
  if $facts['os']['family'] != 'Debian' { fail('Unsupported OS') }

  package { ['apparmor-profiles', 'apparmor-utils']:
    ensure  => installed,
  }

  service { 'apparmor':
    ensure  => running,
    enable  => true,
    require => [
      Package['apparmor-profiles'],
    ],
  }

}
