# harden cron files as per CIS guidelines
#
# https://man7.org/linux/man-pages/man8/cron.8.html

class profile::base::linux::hardening::cron {

  file {
    default:
      owner => 'root',
      group => 'root',
      mode  => '0700',
      audit => all,
    ;
    ['/etc/cron.d', '/etc/cron.daily', '/etc/cron.hourly', '/etc/cron.monthly', '/etc/cron.weekly']:
    ;
    ['/etc/crontab',]:
      mode => '0600',
    ;
  }

}
