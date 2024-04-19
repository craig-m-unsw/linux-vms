#
# Use default distro package manager to manage packages.
#
class profile::base::linux::packages_os (
  Array $packages_adding   = lookup('profile::base::linux::packages::add', {'default_value' => []}),
  Array $packages_removing = lookup('profile::base::linux::packages::remove', {'default_value' => []}),
) {

  # Install packages specified for adding
  if $packages_adding {
    package { $packages_adding:
      ensure => 'installed',
    }
  }

  # Remove packages specified for removal
  if $packages_removing {
    package { $packages_removing:
      ensure => 'purged',
    }
  }

}
