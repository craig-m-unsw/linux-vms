class profile::role_code::example_role::misc {

    file { '/etc/opt/example_role.txt':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => 'an example role',
    }

}