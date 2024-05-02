class role::k8s_worker {

  include profile::base
  include profile::infofile
  include profile::role_code::k8s::worker::node

}
