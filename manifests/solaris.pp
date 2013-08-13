# == Class: nisclient::solaris
#
class nisclient::solaris {
  
  $domainname = $nisclient::domainname
  $package_ensure = $nisclient::package_ensure
  $package_name = $nisclient::package_name
  $service_ensure = $nisclient::service_ensure
  $service_name = $nisclient::service_name

  $default_service_name = 'nis/client'

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

  file { ['/var/yp',
          '/var/yp/binding',
          "/var/yp/binding/${domainname}"]:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => 0644,
  }

  file { "/var/yp/binding/${domainname}/ypservers":
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    require => File["/var/yp/binding/${domainname}"],
    notify  => Exec['domainname'],
    content => "${server}\n",
  }

  exec { 'domainname':
    command     => "/usr/bin/domainname ${domainname}",
    refreshonly => true,
    notify      => Service['nis_service'],
  }

  file { '/etc/defaultdomain':
    ensure  => present,
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template('nisclient/defaultdomain.erb'),
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
