# == Class: nisclient
#
class nisclient(
  $domainname     = $::domain,
  $server         = '127.0.0.1',
  $package_ensure = 'installed',
  $package_name   = undef,
  $service_ensure = 'running',
  $service_name   = undef,
) {

  case $::kernel {
    'Linux': {
      include rpcbind

      case $::osfamily {
        'RedHat', 'Suse': {
          $default_package_name = 'ypbind'
          $default_service_name = 'ypbind'
        }
        'Debian': {
          $default_package_name = 'nis'
          $default_service_name = 'ypbind'
        }
        default: {
          fail("nisclient is not supported on osfamily <${::osfamily}>")
        }
      }

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
        command     => "ypdomainname ${domainname}",
        path        => '/bin:/usr/bin:/sbin:/usr/sbin',
        refreshonly => true,
        notify      => Service['nis_service'],
      }

      case $::osfamily {
        'RedHat': {
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
        'Suse','Debian': {
          file { '/etc/defaultdomain':
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => "${domainname}\n"
          }
        }
        default: {
          fail("Unsupported osfamily ${::osfamily}")
        }
      }
    }
    'SunOS': {
      $default_package_name = ['SUNWnisr', 'SUNWnisu']
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
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
      }

      file { "/var/yp/binding/${domainname}/ypservers":
        ensure  => present,
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
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => "${domainname}\n",
      }
    }
    default: {
      fail("nisclient is only supported on Linux and Solaris kernels. Detected kernel is <${::kernel}>")
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
