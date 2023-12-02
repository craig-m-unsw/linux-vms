class profile::base::filemon {

  file {
    default:
      audit  => all,
    ;
    ['/etc/passwd', '/etc/group', '/etc/services', '/etc/shadow', '/etc/gshadow']:
    ;
  }

}
