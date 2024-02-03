#
# each role should follow a hierarchy using common patterns first,
# down to specific single use blocks of code being least preferable
#
class role::example_role {

  # common code (write more of)
  include profile::base

  # help with debugs
  include profile::infofile
  
  # specific code (write less of)
  include profile::role_code::node::misc

}
