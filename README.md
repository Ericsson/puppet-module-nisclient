puppet-module-nisclient
=======================

Puppet module to manage a NIS client


=== Parameters

domainname
--------------
NIS domain name

- *Default*: example.com

server
--------------
NIS server hostname or IP

- *Default*: 127.0.0.1

package_ensure
--------------
ensure attribute for NIS client package

- *Default*: installed

package_name
--------------
name of NIS client package

- *Default*: undef (OS default)

service_ensure
--------------
ensure attribute for NIS client service

- *Default*: running

service_name
--------------
name of NIS client service

- *Default*: undef (OS default)

