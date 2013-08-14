# == Class: nisclient::linux
#
class nisclient::linux {

  $domainname = $nisclient::domainname
  $server = $nisclient::server
  $package_ensure = $nisclient::package_ensure
  $package_name = $nisclient::package_name
  $service_ensure = $nisclient::service_ensure
  $service_name = $nisclient::service_name

  $default_service_name = 'ypbind'

  case $::osfamily {
    'redhat', 'suse': {
      $default_package_name = 'ypbind'
    }
    'debian': {
      $default_package_name = 'nis'
    }
    default: {
      fail("Module ${module_name} is not supported on osfamily <${::osfamily}>")
    }
  }

  include rpcbind

  if $service_name == undef {
    $my_service_name = $default_service_name
  } else {
    $my_service_name = $service_name
  }
  if $package_name == undef {
    $my_package_name = $default_package_name
  } else {
    $my_package_name = $package_name
  }

  package { 'nis_package':
    ensure => installed,
    name   => $my_package_name,
  }

  file { '/etc/yp.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "domain ${domainname} server ${server}\n",
    require => Package['nis_package'],
    notify  => Exec['ypdomainname'],
  }

  exec { 'ypdomainname':
    command     => "/bin/ypdomainname ${domainname}",
    refreshonly => true,
    notify      => Service['nis_service'],
  }

  if $::osfamily == 'redhat' {
    exec { 'set_nisdomain':
      path    => '/bin',
      command => "echo NISDOMAIN=${domainname} >> /etc/sysconfig/network",
      unless  => 'grep ^NISDOMAIN /etc/sysconfig/network',
    }

    exec { 'change_nisdomain':
      command => "sed -i 's/^NISDOMAIN.*/NISDOMAIN=${domainname}/' /etc/sysconfig/network",
      path    => '/bin',
      unless  => "grep ^NISDOMAIN=${domainname} /etc/sysconfig/network",
      onlyif  => 'grep ^NISDOMAIN /etc/sysconfig/network',
    }
  }
  elsif $::osfamily =~ /Suse|Debian/ {
    file { '/etc/defaultdomain':
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => 0644,
      content => "${domainname}\n"
    }
  }

  if $service_ensure == 'stopped' {
    $service_enable = false
  } else {
    $service_enable = true
  }

  service { 'nis_service':
    ensure => $service_ensure,
    enable => $service_enable,
    name   => $my_service_name,
  }

}
