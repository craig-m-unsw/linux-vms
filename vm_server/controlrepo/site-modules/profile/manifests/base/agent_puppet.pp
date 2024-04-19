#
# puppet node agent ver
#
class profile::base::agent_puppet (
  String $puppet_node_agent_ver = 'latest'
) {
  class { 'puppet_agent':
    package_version => $puppet_node_agent_ver,
    is_pe           => true
  }
}
