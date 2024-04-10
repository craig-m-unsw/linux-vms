#
# an array of folders we want on all Windows systems
#
class profile::base::windows::dirs (
  $windows_base_dirs_pub = ['c:/opt/', 'c:/Users/Public/opt/'],
) {

  file {
    default:
      ensure => 'directory',
      owner  => 'Administrators',
      group  => 'Administrators',
    ;
    $windows_base_dirs_pub:
    ;
  }

}
