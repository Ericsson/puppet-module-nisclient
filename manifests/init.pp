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
      include nisclient::linux
    }
    'SunOS': {
      include nisclient::solaris
    }
    default: {
      fail("nisclient is only supported on Linux and Solaris kernels. Detected kernel is <${::kernel}>")
    }
  }
}
