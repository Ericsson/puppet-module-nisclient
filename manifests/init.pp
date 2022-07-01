# @summary nisclient
#
# Manages the NIS client
#
# @example Declaring the class
#   include nisclient
#
# @param domainname NIS domain name
# @param server NIS server hostname or IP
# @param broadcast On Linux, enable ypbind broadcast mode. If both `broadcast` and `server` options are specified, broadcast mode will be used.
# @param package_ensure ensure attribute for NIS client package
# @param package_name Array of NIS client package(s). 'USE_DEFAULTS' will use platform specific defaults provided by the module. Passing a string is deprecated and only available for easier upgrading.
# @param service_ensure ensure attribute for NIS client service
# @param service_name String name of NIS client service. 'USE_DEFAULTS' will use platform specific defaults provided by the module.
#
class nisclient (
  Stdlib::Fqdn $domainname = $::facts['domain'],
  Stdlib::Host $server = '127.0.0.1',
  Boolean $broadcast = false,
  String[1] $package_ensure = 'installed',
  Variant[Array,String[1]] $package_name = undef,
  String[1] $service_ensure = 'running',
  String[1] $service_name = undef,
) {
  # variable preparations
  case $::facts['os']['family'] {
    'Debian', 'RedHat', 'Suse': {
      $package_before = 'File[/etc/yp.conf]'
    }
    'Solaris': {
      $package_before = undef
    }
    default: {
      fail("nisclient is only supported on RedHat, Solaris, Suse, and Ubuntu osfamilies. Detected osfamily is <${::facts['os']['family']}>")
    }
  }

  case type_of($package_name) {
    'Array': { $package_name_array = $package_name }
    default: { $package_name_array = any2array($package_name) }
  }

  # functionality
  if "${::facts['os']['family']}${::facts['operatingsystemrelease']}" =~ /^(Debian|RedHat(6|7)|Suse)/ {
    include rpcbind
  }

  package { $package_name_array:
    ensure => $package_ensure,
    before => $package_before,
  }

  if $service_ensure == 'stopped' {
    $service_enable = false
  } else {
    $service_enable = true
  }

  service { 'nis_service':
    ensure => $service_ensure,
    name   => $service_name,
    enable => $service_enable,
  }

  case $::facts['os']['family'] {
    'Solaris': {
      file { '/var/yp':
        ensure => directory,
        path   => '/var/yp',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      file { '/var/yp/binding':
        ensure => directory,
        path   => '/var/yp/binding',
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      file { "/var/yp/binding/${domainname}":
        ensure => directory,
        path   => "/var/yp/binding/${domainname}",
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      file { "/var/yp/binding/${domainname}/ypservers":
        ensure  => file,
        path    => "/var/yp/binding/${domainname}/ypservers",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => File["/var/yp/binding/${domainname}"],
        notify  => Exec['domainname'],
        content => "${server}\n",
      }

      exec { 'domainname':
        command     => "domainname ${domainname}",
        path        => '/bin:/usr/bin:/sbin:/usr/sbin',
        refreshonly => true,
        notify      => Service['nis_service'],
      }
    }
    # defaults to Linux systems
    default: {
      file { '/etc/yp.conf':
        ensure  => 'file',
        path    => '/etc/yp.conf',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('nisclient/yp.conf.erb'),
        notify  => Exec['ypdomainname'],
      }

      exec { 'ypdomainname':
        command     => "ypdomainname ${domainname}",
        path        => '/bin:/usr/bin:/sbin:/usr/sbin',
        refreshonly => true,
        notify      => Service['nis_service'],
      }

      if $::facts['os']['family'] == 'RedHat' {
        exec { 'set_nisdomain':
          command => "echo NISDOMAIN=${domainname} >> /etc/sysconfig/network",
          path    => '/bin:/usr/bin:/sbin:/usr/sbin',
          unless  => 'grep ^NISDOMAIN /etc/sysconfig/network',
        }

        exec { 'change_nisdomain':
          command => "sed -i 's/^NISDOMAIN.*/NISDOMAIN=${domainname}/' /etc/sysconfig/network",
          path    => '/bin:/usr/bin:/sbin:/usr/sbin',
          unless  => "grep ^NISDOMAIN=${domainname} /etc/sysconfig/network",
          onlyif  => 'grep ^NISDOMAIN /etc/sysconfig/network',
        }
      }
    }
  }

  case $::facts['os']['family'] {
    'Debian', 'Solaris', 'Suse': {
      file { '/etc/defaultdomain':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "${domainname}\n",
      }
    }
    default: {}
  }
}
