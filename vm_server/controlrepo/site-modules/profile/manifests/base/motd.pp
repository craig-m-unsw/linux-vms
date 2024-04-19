#
# set the message of the day
#
class profile::base::motd (
  String $motd_content = 'Boxlab VM',
) {
  class { 'motd':
    content => "${motd_content}\n",
  }
}
