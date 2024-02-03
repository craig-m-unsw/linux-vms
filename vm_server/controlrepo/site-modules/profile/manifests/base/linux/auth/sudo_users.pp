#
# lookup a hash of data from hiera
#
class profile::base::linux::auth::sudo_users (
    $sudo_info = hiera_hash('profile::base::linux::auth::sudoers', {}),
    $sudo_info_purge = lookup('profile::base::linux::auth::purge_unmanaged_sudo', Boolean, first, false),
) {

    group { 'wheel':
        ensure => 'present',
    }

    package { 'sudo':
        ensure => installed,
    }

    # validate and monitor sudoers file for changes
    file { '/etc/sudoers':
        ensure       => 'present',
        validate_cmd => '/sbin/visudo -cf %',
        audit        => all,
    }

    # remove non-puppet files ?
    file { '/etc/sudoers.d/':
        ensure  => 'directory',
        purge   => $sudo_info_purge,
        recurse => true,
    }

    # iterate over sudo information in hiera
    $sudo_info.each |$user, $sudo_line| {

        $sudoers_file_path    = "/etc/sudoers.d/${user}"
        $sudoers_file_content = $sudo_line[content]

        file { $sudoers_file_path:
            ensure  => file,
            content => "$sudoers_file_content\n",
            mode    => '0440'
        }
    }

}