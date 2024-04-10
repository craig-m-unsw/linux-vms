#
# httpd
#
class profile::base::linux::stacks::apache::apache (
) {

    case $facts['os']['name'] {
        'CentOS': { $apache_pkg = 'httpd' }
        'Redhat': { $apache_pkg = 'httpd' }
        'Debian': { $apache_pkg = 'apache2' }
        'Ubuntu': { $apache_pkg = 'apache2' }
        default: { fail('Unrecognized operating system for webserver.') }
    }

    package { $apache_pkg :
        ensure => present,
    }

}
