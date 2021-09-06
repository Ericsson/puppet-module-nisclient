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
# @param package_name String or Array of NIS client package(s). 'USE_DEFAULTS' will use platform specific defaults provided by the module.
# @param service_ensure ensure attribute for NIS client service
# @param service_name String name of NIS client service. 'USE_DEFAULTS' will use platform specific defaults provided by the module.
#
class nisclient(
  String[1] $domainname = $::facts['domain'],
  Stdlib::Host $server = '127.0.0.1',
  Boolean $broadcast = false,
  String[1] $package_ensure = 'installed',
  String[1] $package_name = 'USE_DEFAULTS',
  String[1] $service_ensure = 'running',
  String[1] $service_name = 'USE_DEFAULTS',
) {
  case $::facts['kernel'] {
    'Linux': {
      case $::facts['os']['family'] {
        'RedHat': {
          $default_package_name = 'ypbind'
          $default_service_name = 'ypbind'

          if $::facts['operatingsystemmajrelease'] in ['6', '7'] {
            include rpcbind
          }
        }
        'Suse': {
          include rpcbind
          $default_package_name = 'ypbind'
          $default_service_name = 'ypbind'
        }
        'Debian': {
          include rpcbind
          $default_package_name = 'nis'
          case $::facts['operatingsystemrelease'] {
            '16.04', '18.04': { $default_service_name = 'nis' }
            # Legacy behavior until Ubuntu 14.04.
            # Unknown status on non-Ubuntu Debian, so keeping default as it was.
            default: { $default_service_name = 'ypbind' }
          }
        }
        default: {
          fail("nisclient supports osfamilies Debian, RedHat, and Suse on the Linux kernel. Detected osfamily is <${::facts['os']['family']}>.")
        }
      }
    }
    'SunOS': {
      case $::facts['kernelrelease'] {
        '5.10':  { $default_package_name = ['SUNWnisr', 'SUNWnisu'] }
        '5.11':  { $default_package_name = ['system/network/nis'] }
        default: { fail("nisclient supports SunOS 5.10 and 5.11. Detected kernelrelease is <${::facts['kernelrelease']}>.") }
      }
      $default_service_name = 'nis/client'
    }
    default: {
      fail("nisclient is only supported on Linux and Solaris kernels. Detected kernel is <${::facts['kernel']}>")
    }
  }

  if $service_name == 'USE_DEFAULTS' {
    $my_service_name = $default_service_name
  } else {
    $my_service_name = $service_name
  }

  if $package_name == 'USE_DEFAULTS' {
    $my_package_name = $default_package_name
  } else {
    $my_package_name = $package_name
  }

  package { $my_package_name:
    ensure => $package_ensure,
  }

  if $service_ensure == 'stopped' {
    $service_enable = false
  } else {
    $service_enable = true
  }

  service { 'nis_service':
    ensure => $service_ensure,
    name   => $my_service_name,
    enable => $service_enable,
  }

  case $::facts['kernel'] {
    'Linux': {
      file { '/etc/yp.conf':
        ensure  => 'file',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('nisclient/yp.conf.erb'),
        require => Package[$my_package_name],
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
      elsif $::facts['os']['family'] in ['Suse', 'Debian'] {
        file { '/etc/defaultdomain':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => "${domainname}\n",
        }
      }
    }
    'SunOS': {
      file { '/var/yp':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      file { '/var/yp/binding':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      file { "/var/yp/binding/${domainname}":
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      file { "/var/yp/binding/${domainname}/ypservers":
        ensure  => file,
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

      file { '/etc/defaultdomain':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "${domainname}\n",
      }
    }
    default: {
      fail("nisclient is only supported on Linux and Solaris kernels. Detected kernel is <${::facts['kernel']}>")
    }
  }
}
