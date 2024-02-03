class profile::infofile (
  $hdata_string = lookup('profile::hdata::test_first', String, first, 'defaultdata'),
  $hdata_combo = lookup('profile::hdata::test_combo', undef, unique, 'defaultdata'),
) {

  # look up role if exists
  if $trusted['extensions']['pp_role'] {
    $my_role = $trusted['extensions']['pp_role']
  } else {
    $my_role = 'none'
  }

  if $facts['kernel'] == 'Windows' {

    file { 'c:\hostinfo.txt':
        ensure  => file,
        content => template('profile/hostinfo.erb'),
    }

  } else {

    # *nix based OS
    file { '/etc/opt/hostinfo.txt':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('profile/hostinfo.erb'),
    }

  }

}