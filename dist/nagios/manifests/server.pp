# Class: nagios::server
#
# This class installs and configures the Nagios server
#
# Parameters:
# * $site_alias
#   DNS Alias for the website
#
# Actions:
#
# Requires:
#   apache
#   nagios::params
#
# Sample Usage:
#
class nagios::server (
    $site_alias = $fqdn,
    $external_commands = false
  ) {

  include apache
  include nagios
  include nagios::commands
  include nagios::contacts
  include nagios::params
  include nagios::hostgroups
  include virtual::nagioscontacts

  # Do we want external commands?
  # http://nagios.sourceforge.net/docs/3_0/extcommands.html
  if $external_commands == true {
    $nagiosexternal = 1
  } else {
    $nagiosexternal = 0
  }

  file { '/etc/nagios/conf.d/nagios_extcommand.cfg':
    mode    => 0644,
    ensure  => present,
    content => template( 'nagios/nagios_extcommand.cfg.erb' ),
    before  => Service[$nagios::params::nagios_service],
  }


  file { [ '/etc/nagios/conf.d/nagios_host.cfg', '/etc/nagios/conf.d/nagios_service.cfg'  ]:
    mode   => 0644,
    ensure => present,
    before => Service[$nagios::params::nagios_service],
  }

  file { [ '/etc/nagios/apache2.conf', '/etc/apache2/conf.d/nagios3.conf' ]:
    ensure => absent,
  }

  file { "/usr/share/nagios3/htdocs/stylesheets":
    ensure => link,
    target => "/etc/nagios3/stylesheets",
  }

  package { $nagios::params::nagios_packages:
    notify  => Service[$nagios::params::nagios_service],
  }

  service { $nagios::params::nagios_service:
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

#  apache::vhost::redirect {
#    "$site_alias":
#      port => 80,
#      dest => "https://${site_alias}",
#  }

  apache::vhost { "${site_alias}":
    port          => '80',
    serveraliases => "$site_alias",
    priority      => '30',
    ssl           => false,
    docroot       => '/usr/share/nagios3/htdocs',
    template      => 'nagios/nagios-apache.conf.erb',
    require       => [ File['/etc/nagios/apache2.conf'], Package[$nagios::params::nagios_packages] ], 
  }

  #apache::vhost { 'nagios.puppetlabs.com_ssl':
  #  port => '443',
  #  priority => '31',
  #	ssl      => 'true',
  #  docroot => '/usr/share/nagios3/htdocs',
  #  template => 'nagios/nagios-apache.conf.erb',
  #  require => [ File['/etc/nagios/apache2.conf'], Package[$nagios::params::nagios_packages] ], 
  #}

  Nagios_host <<||>>
  Nagios_service <<||>>
}

