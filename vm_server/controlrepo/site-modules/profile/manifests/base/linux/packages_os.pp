#
# use default distro package manager to install or remove 
# packages listed in hiera (if any)
#
class profile::base::linux::packages_os (
  Array $packages_adding   = lookup('profile::base::linux::packages::add', Array, unique, []),
  Array $packages_removing = lookup('profile::base::linux::packages::remove', Array, unique, []),
) {

    $packages_adding.each |$package| {
      package { $package:
        ensure => 'installed',
      }
    }

    $packages_removing.each |$package| {
      package { $package:
        ensure => 'purged',
      }
    }

}
