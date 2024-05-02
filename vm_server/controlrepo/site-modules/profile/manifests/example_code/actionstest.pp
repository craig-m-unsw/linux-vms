#
# test code: run x4 command only x1 (idempotency)
#
class profile::example_code::actionstest (
  String $testfile = '/etc/opt/testrun.txt',
) {

  notify { 'resource title':
    message => 'running actionstest',
  }

  exec { 'check_file':
    command     => '/bin/true',
    path        => ['/usr/bin', '/usr', '/usr/sbin'],
    unless      => "test ! -e ${testfile}",
    refreshonly => true,
  }

  #  only run if /etc/opt/testrun.txt exists
  if !defined(Exec['check_file']) {

    notify { 'resource title':
      message => 'running actionstest conditional',
    }

    exec { 'test_run_1':
      command     => 'echo command-foo-1 | logger',
      path        => ['/usr/bin', '/usr', '/usr/sbin'],
      refreshonly => true,
    } -> exec { 'test_run_2':
      command     => 'echo ommand-foo-2 | logger',
      path        => ['/usr/bin', '/usr', '/usr/sbin'],
      refreshonly => true,
    } -> exec { 'test_run_3':
      command     => 'echo ommand-foo-3 | logger',
      path        => ['/usr/bin', '/usr', '/usr/sbin'],
      refreshonly => true,
    } -> exec { 'test_run_4':
      command     => 'echo ommand-foo-4 | logger',
      path        => ['/usr/bin', '/usr', '/usr/sbin'],
      refreshonly => true,
    } -> exec { 'make_test_file':
      command     => "touch ${testfile}",
      path        => ['/usr/bin', '/usr', '/usr/sbin'],
      refreshonly => true,
    }

  }

}
