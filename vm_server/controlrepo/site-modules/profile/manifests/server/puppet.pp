class profile::server::puppet {

  package { 'puppet-lint':
    ensure   => present,
    provider => puppetserver_gem,
  }

}
