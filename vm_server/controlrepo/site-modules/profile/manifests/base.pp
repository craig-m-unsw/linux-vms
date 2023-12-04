class profile::base {

  include profile::base::motd

  if $facts['kernel'] == 'Linux' {
    include profile::base::linux::dirs
    include profile::base::linux::filemon
  }

}
