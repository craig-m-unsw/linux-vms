## site.pp ##

# This file (./manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
# https://puppet.com/docs/puppet/latest/dirs_manifest.html
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition if you want to use it.

## Active Configurations ##

# Disable filebucket by default for all File resources:
# https://github.com/puppetlabs/docs-archive/blob/master/pe/2015.3/release_notes.markdown#filebucket-resource-no-longer-created-by-default
File { backup => false }

## Node Definitions ##

# The default node definition matches any node lacking a more specific node
# definition. If there are no other node definitions in this file, classes
# and resources declared in the default node definition will be included in
# every node's catalog.
#
# Note that node definitions in this file are merged with node data from the
# Puppet Enterprise console and External Node Classifiers (ENC's).
#
# For more on node definitions, see: https://puppet.com/docs/puppet/latest/lang_node_definitions.html

node default {

    # trusted role
    if $trusted['extensions']['pp_role'] {
        include "role::${trusted['extensions']['pp_role']}"
    }

    # Puppet enterprise
    $hosts_server_puppet = ['puppet.local', 'puppet.mylocal', 'puppet.internal']
    if $trusted['certname'] in $hosts_server_puppet {
        include 'role::server_puppet'
    }

    # windows hosts (temp)
    $hosts_ms_windows = ['windows11.local', 'windows11', 'windows11.mylocal']
    if $trusted['certname'] in $hosts_ms_windows {
        include 'role::node'
    }

}