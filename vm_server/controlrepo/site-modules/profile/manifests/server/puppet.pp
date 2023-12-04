class profile::server::puppet {

  package { 'hiera-eyaml':
    ensure   => present,
    provider => puppetserver_gem,
  }

  package { 'puppet-lint':
    ensure   => present,
    provider => puppetserver_gem,
  }

}
