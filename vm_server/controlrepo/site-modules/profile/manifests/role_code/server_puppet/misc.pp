class profile::role_code::server_puppet::misc {

  package { 'puppet-lint':
    ensure   => present,
    provider => puppetserver_gem,
  }

  file { '/etc/opt/pe.txt':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => 'PE role',
  }

}