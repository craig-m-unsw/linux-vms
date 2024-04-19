#
# base code for all hosts
#
class profile::base {
  include profile::base::agent_puppet
  if $facts['kernel'] == 'Linux' {
    include cron
    include profile::base::motd
    include profile::base::linux::dirs
    include profile::base::linux::filemon
    include profile::base::linux::auth::root_auth
    include profile::base::linux::auth::sudo_configs
    include profile::base::linux::auth::wheel_group
    include profile::base::linux::ssh
    include profile::base::linux::packages_os
    include profile::base::linux::hardening::cron
    include profile::base::linux::hardening::netproto
    # distro family specifics
    case $facts['os']['name'] {
      'RedHat', 'CentOS', 'Rocky': {
        include profile::base::linux::distro::rhel_based::selinux
      }
      /^(Debian|Ubuntu)$/: {
        include profile::base::linux::distro::debian_based::apparmor
        include profile::base::linux::distro::ubuntu::gui
      }
      default: {
      }
    }
  }
  if $facts['kernel'] == 'Windows' {
    include profile::base::windows::dirs
    include profile::base::windows::filemon
  }
}
