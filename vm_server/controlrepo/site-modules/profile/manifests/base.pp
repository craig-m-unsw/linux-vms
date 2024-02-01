class profile::base {

  if $facts['kernel'] == 'Linux' {
    include profile::base::motd
    include profile::base::linux::dirs
    include profile::base::linux::filemon
  }

}
