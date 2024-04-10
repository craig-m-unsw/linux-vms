#
# create the fact in /opt/puppetlabs/facter/facts.d/custom_facts.yaml
# with content like this:
#
# desktop_environment: gnome
#
#
class profile::base::linux::distro::rocky::gui (
  String $desktop_environment = $facts['desktop_environment']
) {

  case $desktop_environment {

    'gnome': {
      package { 'gnome-desktop3':
        ensure => present,
        notify => Exec[set_graphical_env],
      }
      exec { 'set_graphical_env':
        path        => ['/bin', '/sbin', '/usr/bin'],
        command     => 'systemctl set-default graphical.target',
        refreshonly => true,
      }
    }

    'kde': {
      package { 'epel-release':
        ensure => present,
        notify => Exec[set_graphical_env],
      }
      exec { 'set_graphical_env':
        path        => ['/bin', '/sbin', '/usr/bin'],
        command     => 'systemctl set-default graphical.target',
        refreshonly => true,
      }
    }

    default: {
      # set text mode
      exec { 'set_server_tty':
        path        => ['/bin', '/sbin', '/usr/bin'],
        command     => 'systemctl set-default multi-user.target',
        refreshonly => true,
      }
    }

  }

}
