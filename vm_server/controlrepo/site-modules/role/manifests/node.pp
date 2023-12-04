class role::node {

  include profile::base
  include profile::infofile

  #if ($facts['os']['name'] in ['Ubuntu','Debian']) {
  #  include profile::base::linux::ubuntu::debsig_verify
  #}

  #if ($facts['os']['name'] in ['Red Hat','CentOS','Fedora']) {
  #  include profile::base::linux::redhat::selinux
  #}

}
