#
# infofile - for testing, help make sense of puppet hosts
#
# https://www.puppet.com/docs/puppet/8/lang_template_erb
# https://www.puppet.com/docs/puppet/8/lang_template_epp
#
class profile::infofile (
  String  $infofile_fixed        = 'foobar1234',
  # write hostinfo.txt y/n
  Boolean $infofile_enabled      = lookup('profile::infofile::enabled', Boolean, first, true),
  # lookup data
  String  $infofile_env          = $server_facts['environment'],
  String  $infofile_string       = lookup('profile::infofile::test_first', String, first, 'defaultdata'),
  String  $infofile_string_empty = lookup('profile::infofile::empty', String, first, 'defaultdata'),
  Array   $infofile_combo        = lookup('profile::infofile::test_combo', undef, unique, 'defaultdata'),
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

  if $infofile_enabled {
    # windows
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

}
