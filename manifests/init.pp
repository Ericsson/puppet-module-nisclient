# == Class: nisclient
#
class nisclient(
  $domainname     = $::domain,
  $server         = '127.0.0.1',
  $broadcast      = false,
  $package_ensure = 'installed',
  $package_name   = 'USE_DEFAULTS',
  $service_ensure = 'running',
  $service_name   = 'USE_DEFAULTS',
) {

  if type3x($broadcast) == 'String' {
    $broadcast_real = str2bool($broadcast)
  } else {
    $broadcast_real = $broadcast
  }
  validate_bool($broadcast_real)

  case $::kernel {
    'Linux': {
      case $::osfamily {
        'RedHat': {
          $default_package_name = 'ypbind'
          $default_service_name = 'ypbind'

          case $::operatingsystemmajrelease {
            '6', '7': { include ::rpcbind }
            default:  { }
          }
        }
        'Suse': {
          include ::rpcbind
          $default_package_name = 'ypbind'
          $default_service_name = 'ypbind'
        }
        'Debian': {
          include ::rpcbind
          $default_package_name = 'nis'
          case $::operatingsystemrelease {
            '16.04', '18.04': { $default_service_name = 'nis' }
            # Legacy behavior until Ubuntu 14.04.
            # Unknown status on non-Ubuntu Debian, so keeping default as it was.
            default: { $default_service_name = 'ypbind' }
          }
        }
        default: {
          fail("nisclient supports osfamilies Debian, RedHat, and Suse on the Linux kernel. Detected osfamily is <${::osfamily}>.")
        }
      }
    }
    'SunOS': {
      case $::kernelrelease {
        '5.10':  { $default_package_name = [ 'SUNWnisr', 'SUNWnisu', ] }
        '5.11':  { $default_package_name = [ 'system/network/nis', ] }
        default: { fail("nisclient supports SunOS 5.10 and 5.11. Detected kernelrelease is <${::kernelrelease}>.") }
      }
      $default_service_name = 'nis/client'
    }
    default: {
      fail("nisclient is only supported on Linux and Solaris kernels. Detected kernel is <${::kernel}>")
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

  case $::kernel {
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
        path        => [ '/bin',
                          '/usr/bin',
                          '/sbin',
                          '/usr/sbin',
                        ],
        refreshonly => true,
        notify      => Service['nis_service'],
      }

      if $::osfamily == 'RedHat' {
        exec { 'set_nisdomain':
          command => "echo NISDOMAIN=${domainname} >> /etc/sysconfig/network",
          path    => [ '/bin',
                        '/usr/bin',
                        '/sbin',
                        '/usr/sbin',
                      ],
          unless  => 'grep ^NISDOMAIN /etc/sysconfig/network',
        }

        exec { 'change_nisdomain':
          command => "sed -i 's/^NISDOMAIN.*/NISDOMAIN=${domainname}/' /etc/sysconfig/network",
          path    => [ '/bin',
                        '/usr/bin',
                        '/sbin',
                        '/usr/sbin',
                      ],
          unless  => "grep ^NISDOMAIN=${domainname} /etc/sysconfig/network",
          onlyif  => 'grep ^NISDOMAIN /etc/sysconfig/network',
        }
      }
      elsif $::osfamily =~ /Suse|Debian/ {
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
      file { ['/var/yp',
              '/var/yp/binding',
              "/var/yp/binding/${domainname}"]:
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
        path        => [ '/bin',
                          '/usr/bin',
                          '/sbin',
                          '/usr/sbin',
                        ],
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
      fail("nisclient is only supported on Linux and Solaris kernels. Detected kernel is <${::kernel}>")
    }
  }
}
