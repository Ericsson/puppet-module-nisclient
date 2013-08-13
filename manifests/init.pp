# == Class: nisclient
#
class nisclient(
  $domainname     = 'example.com',
  $server         = '127.0.0.1',
  $package_ensure = 'installed',
  $package_name   = undef,
  $service_ensure = 'running',
  $service_name   = undef
) {

  case $::kernel {
    'linux': {
      include nisclient::linux
    }
    'solaris': {
      include nisclient::solaris
    }
    default: {
      fail("${module_name} is only supported on Linux and Solaris. Not on ${::kernel}")
    }
  }

}
