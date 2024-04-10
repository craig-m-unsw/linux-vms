#
# https://www.puppet.com/docs/puppet/8/lang_template_erb
# https://www.puppet.com/docs/puppet/8/lang_template_epp
#
class profile::infofile (
  String $hdata_string = lookup('profile::hdata::test_first', String, first, 'defaultdata'),
  Array $hdata_combo  = lookup('profile::hdata::test_combo', undef, unique, 'defaultdata'),
  String $hdata_fixed = 'foobar123',
  String $hdata_env = $server_facts['environment']
) {

  # look up role if exists
  if $trusted['extensions']['pp_role'] {
    $my_role = $trusted['extensions']['pp_role']
  } else {
    $my_role = 'none'
  }

  if $trusted['extensions']['pp_area'] {
    $functional_area = $trusted['extensions']['pp_area']
  } else {
    $functional_area = 'none'
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
