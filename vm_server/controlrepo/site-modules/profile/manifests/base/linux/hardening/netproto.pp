#
# disable uncommon network protocols
#
class profile::base::linux::hardening::netproto {

  file {
    default:
      ensure => 'file',
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
    ;
    ['/etc/modprobe.d/dccp.conf',]:
      content => 'install dccp /bin/true',
    ;
    ['/etc/modprobe.d/rds.conf',]:
      content => 'install rds /bin/true',
    ;
    ['/etc/modprobe.d/sctp.conf',]:
      content => 'install sctp /bin/true',
    ;
    ['/etc/modprobe.d/tipc.conf',]:
      content => 'install tipc /bin/true',
    ;
  }

}
