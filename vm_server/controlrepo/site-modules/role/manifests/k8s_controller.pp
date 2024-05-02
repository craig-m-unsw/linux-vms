class role::k8s_controller {

  include profile::base
  include profile::infofile
  include profile::role_code::k8s::controller::node

}
