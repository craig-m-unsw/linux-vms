#
# monitor these files on windows host
#
class profile::base::windows::filemon (
  $windows_filemon_default = ['c:\Windows\System32\drivers\etc\hosts'],
  $windows_filemon = lookup('profile::base::windows::filemon', Array, unique, $windows_filemon_default),
) {

  file {
    default:
      audit  => all,
    ;
    $windows_filemon:
    ;
  }

}
