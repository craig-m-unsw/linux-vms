#
# create the fact in /opt/puppetlabs/facter/facts.d/custom_facts.yaml
# with content like this:
#
#   ---
#   desktop_environment: gnome
#
class profile::base::linux::distro::ubuntu::gui (
  String $desktop_environment = $facts['desktop_environment']
) {

  case $desktop_environment {
    'gnome': {
      package { 'ubuntu-desktop':
        ensure  => present,
      }
      package { ['gdm3', 'gnome-keyring-pkcs11' ,'gnome-keyring' , 'libpam-gnome-keyring', 'gnome-screensaver']:
        ensure  => installed,
      }
      file { '/etc/dconf/profile/gdm':
        ensure  => file,
        content => "user-db:user\nsystem-db:gdm\nfile-db:/usr/share/gdm/greeter-dconf-defaults",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
      }
      file { '/etc/dconf/db/gdm.d/':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }
      file { '/etc/dconf/db/gdm.d/00-login-screen':
        ensure  => file,
        content => "[org/gnome/login-screen]\n# Do not show the user list\ndisable-user-list=true\n",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Exec[update_gnome_login_conf],
      }
      exec { 'update_gnome_login_conf':
        path        => ['/bin', '/sbin', '/usr/bin'],
        command     => 'dconf update',
        refreshonly => true,
      }
    }
    'kde': {
      package { 'kubuntu-desktop':
        ensure  => present,
      }
      package { ['sddm', 'libpam-kwallet-common', 'gnome-keyring-pkcs11','gnome-keyring']:
        ensure => installed,
      }
      file { '/etc/sddm.conf':
        ensure  => file,
        content => "# Do not show the user list\n[Users]\nMaximumUid=99999\nMinimumUid=99999\nRememberLastUser=false\n",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
      }
  }
    # set text mode as default
    default: {
      exec { 'set_server_tty':
        path        => ['/bin', '/sbin', '/usr/bin'],
        command     => 'systemctl set-default multi-user.target',
        refreshonly => true,
      }
    }
  }

}
