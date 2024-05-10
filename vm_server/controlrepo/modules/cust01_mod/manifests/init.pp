# @summary A short summary of the purpose of this class
#
# the init
#
class cust01_mod::init {
  file { '/tmp/test_file':
    ensure => file,
    content => "This is a test file created by Puppet.",
  }
}