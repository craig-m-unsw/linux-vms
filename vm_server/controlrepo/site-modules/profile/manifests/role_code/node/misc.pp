#
#
# $ mkpasswd -m sha512crypt --stdin <<< "vagrant"
#
class profile::role_code::node::misc (
    $vagrant_user_pass = Sensitive(lookup('profile::roledata::linux::vagrantpass', String, first, '')),
) {

    $vagrant_user_pass_unwrap = $vagrant_user_pass.unwrap

    user { 'vagrant':
        ensure   => 'present',
        password => $vagrant_user_pass_unwrap,
    }

    if $facts['kernel'] == 'Linux' {

        # flag any users not managed by puppet
        resources { 'user':
            purge              => true,
            unless_system_user => true,
            noop               => true
        }

        # copy file from repo
        file { '/etc/opt/boxlab.txt':
            source => 'puppet:///modules/profile/common/boxlab.txt',
            owner  => 'root',
            group  => 'root',
            mode   => '0444',
        }

    }

}
