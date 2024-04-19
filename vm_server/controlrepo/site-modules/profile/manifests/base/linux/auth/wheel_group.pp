# change puppet_wheel users in /etc/group
#
class profile::base::linux::auth::wheel_group (
  Array  $wheel_group_user = ['test11', 'test2', 'test33'],
  String $wheel_group_name = 'puppet_wheel',
  String $wheel_group_gid  = '1111',
) {

  group { $wheel_group_name:
    ensure => 'present',
    gid    => $wheel_group_gid,
  }

  $wheel_users_string = join($wheel_group_user, ',')

  file_line { 'puppet_wheel_etc_group':
    path               => '/etc/group',
    line               => "${$wheel_group_name}:x:${wheel_group_gid}:${wheel_users_string}",
    match              => "${$wheel_group_name}:x:\d+:",
    append_on_no_match => false,
  }

}
