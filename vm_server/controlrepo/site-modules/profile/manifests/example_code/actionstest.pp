#
# test code
#
class profile::example_code::actionstest (
  String $foobar = 'test',
) {

  notify { 'resource title':
    message => 'running actionstest',
  }

  exec { 'check_file':
    command     => '/bin/true',
    path        => ['/usr/bin', '/usr', '/usr/sbin'],
    unless      => 'test ! -e /etc/opt/testrun.txt',
    refreshonly => true,
  }

  #  only run if /etc/opt/testrun.txt exists
  if !defined(Exec['check_file']) {

    notify { 'resource title':
      message => 'running actionstest conditional',
    }

    exec { 'test_run_1':
      command     => 'echo foobar1 | logger',
      path        => ['/usr/bin', '/usr', '/usr/sbin'],
      refreshonly => true,
    } -> exec { 'test_run_2':
      command     => 'echo foobar2 | logger',
      path        => ['/usr/bin', '/usr', '/usr/sbin'],
      refreshonly => true,
    } -> exec { 'test_run_3':
      command     => 'echo foobar3 | logger',
      path        => ['/usr/bin', '/usr', '/usr/sbin'],
      refreshonly => true,
    } -> exec { 'test_run_4':
      command     => 'echo foobar4 | logger',
      path        => ['/usr/bin', '/usr', '/usr/sbin'],
      refreshonly => true,
    } -> exec { 'test_run_5':
      command     => 'touch /etc/opt/testrun1.txt',
      path        => ['/usr/bin', '/usr', '/usr/sbin'],
      refreshonly => true,
    }

  }

}
