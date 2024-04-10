#
# On our Linux systems we always want to know when these files get altered
# even if the files are not managed we want to monitor for any changes (nefarious or otherwise)
#
# lookup this array, or use this default if hiera data is missing
#
class profile::base::linux::filemon (
  Array $linux_filemon_default = ['/etc/passwd', '/etc/group', '/etc/shadow', '/etc/gshadow',],
  Array $linux_filemon = lookup('profile::base::linux::filemon', Array, unique, $linux_filemon_default),
) {

  file {
    default:
      audit => all,
    ;
    $linux_filemon:
    ;
  }

}
