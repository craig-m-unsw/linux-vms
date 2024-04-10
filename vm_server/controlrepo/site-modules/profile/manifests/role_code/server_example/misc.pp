class profile::role_code::server_example::misc {

    if ($trusted['extensions']['pp_role'] != 'server_example') { fail('ERROR wrong include') }

    file { '/etc/opt/example_role.txt':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => 'an example role',
    }

}