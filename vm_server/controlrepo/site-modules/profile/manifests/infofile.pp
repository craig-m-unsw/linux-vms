class profile::infofile (
  $verdata_string = lookup('profile::verdata::teststring', String, first, "defaultdata"),
) {

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

    file { '/etc/opt/hostinfo.txt':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('profile/hostinfo.erb'),
    }

  }

}