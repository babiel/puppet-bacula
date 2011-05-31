# Class: puppet
#
# This class installs and configures Puppet
#
# Parameters:
#
# Actions:
# - Install Puppet
#
# Requires:
#
# Sample Usage:
#
class puppet ($server){
  include ruby
  include puppet::params
  include concat::setup

  $puppet_server   = $server
  $puppet_storedconfig_password = $puppet::params::puppet_storedconfig_password
  $puppetd_service = $puppet::params::puppetd_service
  $puppet_conf     = $puppet::params::puppet_conf
  $puppet_logdir   = $puppet::params::puppet_logdir
  $puppet_vardir   = $puppet::params::puppet_vardir
  $puppet_ssldir   = $puppet::params::puppet_ssldir

  package { 'puppet':
    ensure => installed,
  }

  if $operatingsystem == "Linux" {
    file { $puppet::params::puppetd_defaults:
      mode   => '0644',
      owner  => 'root',
      group  => 'root',
      source => "puppet:///modules/puppet/${puppet::params::puppetd_defaults}",
    }
  }

  service { "puppetd":
    name       => "$puppetd_service",
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

#  file { '/etc/puppet/puppet.conf':
#    content => $fqdn ? {
#      $puppet_server => template('puppet/puppet-server.conf.erb'),
#      default => template('puppet/puppet.conf.erb'),
#    },
#    notify => Service["puppetd"],
#    require => Package['puppet'],
#  }

  concat::fragment { 'puppet.conf-common':
    order   => '00',
    target  => "$puppet::params::puppet_conf",
    content => template("puppet/puppet.conf-common.erb");
  }

  concat { "$puppet::params::puppet_conf":
    mode    => '0644',
    notify  => Service["puppetd"],
    require => Package['puppet'];
  }

}

