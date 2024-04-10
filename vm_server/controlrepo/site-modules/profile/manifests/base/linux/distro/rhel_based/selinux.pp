#
# manage selinux
#
# REQUIRES https://forge.puppet.com/modules/puppet/selinux
#
class profile::base::linux::distro::rhel_based::selinux (
  String $selinux_mode = 'permissive',
  String $selinux_type = 'targeted',
) {

  class { 'selinux':
    mode => $selinux_mode,
    type => $selinux_type,
  }

}
