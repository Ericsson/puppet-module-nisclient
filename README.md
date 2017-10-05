puppet-module-nisclient
=======================

Puppet module to manage a NIS client

[![Build Status](https://travis-ci.org/Ericsson/puppet-module-nisclient.png?branch=master)](https://travis-ci.org/Ericsson/puppet-module-nisclient)

===

# Compatability

This module has been tested to work on the following systems with Puppet v3
(with and without the future parser) and Puppet v4 with Ruby versions 1.8.7,
1.9.3, 2.0.0, 2.1.0 and 2.3.1.

 * EL 5
 * EL 6
 * EL 7
 * Suse 11
 * Suse 12
 * Solaris 10
 * Solaris 11
 * Ubuntu 12.04 LTS
 * Ubuntu 14.04 LTS
 * Ubuntu 16.04 LTS

===

# Parameters

domainname
----------
NIS domain name

- *Default*: value of `domain` fact

server
------
NIS server hostname or IP

- *Default*: '127.0.0.1'

broadcast
---------
Boolean. On Linux, enable ypbind broadcast mode. If both `broadcast` and `server` options are specified, broadcast mode will be used.

- *Default*: false

package_ensure
--------------
ensure attribute for NIS client package

- *Default*: installed

package_name
------------
String or Array of NIS client package(s). 'USE_DEFAULTS' will use platform specific defaults provided by the module.

- *Default*: 'USE_DEFAULTS'

service_ensure
--------------
ensure attribute for NIS client service

- *Default*: running

service_name
------------
String name of NIS client service. 'USE_DEFAULTS' will use platform specific defaults provided by the module.

- *Default*: 'USE_DEFAULTS'
