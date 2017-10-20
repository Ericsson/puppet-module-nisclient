require 'spec_helper'
describe 'nisclient' do

  describe 'on kernel Linux' do
    context 'with default params on EL 5' do
      let :facts do
        { :domain            => 'example.com',
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '5',
        }
      end

      it { should_not contain_class('rpcbind') }

      it {
        should contain_package('ypbind').with({
          'ensure' => 'installed',
        })
      }

      it {
        should contain_file('/etc/yp.conf').with({
          'ensure' => 'file',
          'path'   => '/etc/yp.conf',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
          'require' => 'Package[ypbind]',
          'notify'  => 'Exec[ypdomainname]',
        })
      }

      it { should contain_file('/etc/yp.conf').with_content(/^# This file is being maintained by Puppet.\n# DO NOT EDIT\ndomain example.com server 127.0.0.1\n$/) }

      it {
        should contain_exec('ypdomainname').with({
          'command'     => 'ypdomainname example.com',
          'path'        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
          'refreshonly' => 'true',
          'notify'      => 'Service[nis_service]',
        })
      }

      it {
        should contain_exec('set_nisdomain').with({
          'command' => 'echo NISDOMAIN=example.com >> /etc/sysconfig/network',
          'path'    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
          'unless'  => 'grep ^NISDOMAIN /etc/sysconfig/network',
        })
      }

      it {
        should contain_exec('change_nisdomain').with({
          'command' => 'sed -i \'s/^NISDOMAIN.*/NISDOMAIN=example.com/\' /etc/sysconfig/network',
          'path'    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
          'unless'  => 'grep ^NISDOMAIN=example.com /etc/sysconfig/network',
          'onlyif'  => 'grep ^NISDOMAIN /etc/sysconfig/network',
        })
      }

      it {
        should contain_service('nis_service').with({
          'ensure' => 'running',
          'name'   => 'ypbind',
          'enable' => 'true',
        })
      }
    end

    context 'with default params on EL 6' do
      let :facts do
        { :domain            => 'example.com',
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end

      it { should contain_class('rpcbind') }

      it {
        should contain_package('ypbind').with({
          'ensure' => 'installed',
        })
      }

      it {
        should contain_file('/etc/yp.conf').with({
          'ensure' => 'file',
          'path'   => '/etc/yp.conf',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
          'require' => 'Package[ypbind]',
          'notify'  => 'Exec[ypdomainname]',
        })
      }

      it { should contain_file('/etc/yp.conf').with_content(/^# This file is being maintained by Puppet.\n# DO NOT EDIT\ndomain example.com server 127.0.0.1\n$/) }

      it {
        should contain_exec('ypdomainname').with({
          'command'     => 'ypdomainname example.com',
          'path'        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
          'refreshonly' => 'true',
          'notify'      => 'Service[nis_service]',
        })
      }

      it {
        should contain_exec('set_nisdomain').with({
          'command' => 'echo NISDOMAIN=example.com >> /etc/sysconfig/network',
          'path'    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
          'unless'  => 'grep ^NISDOMAIN /etc/sysconfig/network',
        })
      }

      it {
        should contain_exec('change_nisdomain').with({
          'command' => 'sed -i \'s/^NISDOMAIN.*/NISDOMAIN=example.com/\' /etc/sysconfig/network',
          'path'    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
          'unless'  => 'grep ^NISDOMAIN=example.com /etc/sysconfig/network',
          'onlyif'  => 'grep ^NISDOMAIN /etc/sysconfig/network',
        })
      }

      it {
        should contain_service('nis_service').with({
          'ensure' => 'running',
          'name'   => 'ypbind',
          'enable' => 'true',
        })
      }
    end

    context 'with default params on Suse' do
      let :facts do
        {
          :domain   => 'example.com',
          :kernel   => 'Linux',
          :osfamily => 'Suse',
        }
      end

      it { should contain_class('rpcbind') }

      it {
        should contain_package('ypbind').with({
          'ensure' => 'installed',
        })
      }

      it {
        should contain_file('/etc/yp.conf').with({
          'ensure' => 'file',
          'path'   => '/etc/yp.conf',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
          'require' => 'Package[ypbind]',
          'notify'  => 'Exec[ypdomainname]',
        })
      }

      it { should contain_file('/etc/yp.conf').with_content(/^# This file is being maintained by Puppet.\n# DO NOT EDIT\ndomain example.com server 127.0.0.1\n$/) }

      it {
        should contain_exec('ypdomainname').with({
          'command'     => 'ypdomainname example.com',
          'path'        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
          'refreshonly' => 'true',
          'notify'      => 'Service[nis_service]',
        })
      }

      it {
        should contain_file('/etc/defaultdomain').with({
          'ensure' => 'file',
          'path'   => '/etc/defaultdomain',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
      }

      it { should contain_file('/etc/defaultdomain').with_content(/^example.com\n$/) }

      it {
        should contain_service('nis_service').with({
          'ensure' => 'running',
          'name'   => 'ypbind',
          'enable' => 'true',
        })
      }
    end

    context 'with defaults params on Ubuntu' do
      let :facts do
        {
          :domain    => 'example.com',
          :kernel    => 'Linux',
          :osfamily  => 'Debian',
          :lsbdistid => 'Ubuntu',
        }
      end

      it { should contain_class('rpcbind') }

      it {
        should contain_package('nis').with({
          'ensure' => 'installed',
        })
      }

      it {
        should contain_file('/etc/yp.conf').with({
          'ensure' => 'file',
          'path'   => '/etc/yp.conf',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
          'require' => 'Package[nis]',
          'notify'  => 'Exec[ypdomainname]',
        })
      }

      it { should contain_file('/etc/yp.conf').with_content(/^# This file is being maintained by Puppet.\n# DO NOT EDIT\ndomain example.com server 127.0.0.1\n$/) }

      it {
        should contain_exec('ypdomainname').with({
          'command'     => 'ypdomainname example.com',
          'path'        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
          'refreshonly' => 'true',
          'notify'      => 'Service[nis_service]',
        })
      }

      it {
        should contain_file('/etc/defaultdomain').with({
          'ensure' => 'file',
          'path'   => '/etc/defaultdomain',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
      }

      it { should contain_file('/etc/defaultdomain').with_content(/^example.com\n$/) }

      it {
        should contain_service('nis_service').with({
          'ensure' => 'running',
          'name'   => 'ypbind',
          'enable' => 'true',
        })
      }

      context 'with version 16.04' do
        let :facts do
          {
            :operatingsystemrelease => '16.04',
          }
        end

        it {
          should contain_service('nis_service').with({
            'ensure' => 'running',
            'name'   => 'nis',
            'enable' => 'true',
          })
      end
    end

    context 'with defaults params on unsupported osfamily' do
      let :facts do
        {
          :domain   => 'example.com',
          :kernel   => 'Linux',
          :osfamily => 'Unsupported',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('nisclient')
        }.to raise_error(Puppet::Error,/nisclient supports osfamilies Debian, RedHat, and Suse on the Linux kernel. Detected osfamily is <Unsupported>./)
      end
    end
  end

  describe 'with parameter broadcast' do
    ['true',true].each do |value|
      context "set to #{value}" do
        let :facts do
            { :domain            => 'example.com',
              :kernel            => 'Linux',
              :osfamily          => 'RedHat',
              :lsbmajdistrelease => '6',
            }
        end

        let :params do {
            :broadcast  => value,
        } end

        it { should contain_file('/etc/yp.conf').with_content(/^domain example\.com broadcast$/) }
      end
    end

    ['false',false].each do |value|
      context "set to #{value}" do
        let :facts do
            { :domain            => 'example.com',
              :kernel            => 'Linux',
              :osfamily          => 'RedHat',
              :lsbmajdistrelease => '6',
            }
        end

        let :params do {
            :broadcast  => value,
        } end

        it { should contain_file('/etc/yp.conf').with_content(/^domain example\.com server 127\.0\.0\.1$/) }
      end
    end

    context 'set to an invalid value' do
      let :facts do
          { :domain            => 'example.com',
            :kernel            => 'Linux',
            :osfamily          => 'RedHat',
          }
      end

      let :params do {
          :broadcast  => 'invalid',
      } end

      it 'should fail' do
        expect {
          should contain_class('nisclient')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  describe 'on kernel SunOS' do
    context 'with defaults params on Solaris 5.10' do
      let :facts do
        {
          :domain        => 'example.com',
          :kernel        => 'SunOS',
          :osfamily      => 'Solaris',
          :kernelrelease => '5.10',
        }
      end

      it { should_not contain_class('rpcbind') }

      it {
        should contain_package('SUNWnisr').with({
          'ensure' => 'installed',
        })
      }

      it {
        should contain_package('SUNWnisu').with({
          'ensure' => 'installed',
        })
      }

      it {
        should contain_file('/var/yp').with({
          'ensure' => 'directory',
          'path'   => '/var/yp',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
        })
      }

      it {
        should contain_file('/var/yp/binding').with({
          'ensure' => 'directory',
          'path'   => '/var/yp/binding',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
        })
      }

      it {
        should contain_file('/var/yp/binding/example.com').with({
          'ensure' => 'directory',
          'path'   => '/var/yp/binding/example.com',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
        })
      }

      it {
        should contain_file('/var/yp/binding/example.com/ypservers').with({
          'ensure'  => 'file',
          'path'    => '/var/yp/binding/example.com/ypservers',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'File[/var/yp/binding/example.com]',
          'notify'  => 'Exec[domainname]',
        })
      }

      it { should contain_file('/var/yp/binding/example.com/ypservers').with_content(/^127.0.0.1\n$/) }

      it {
        should contain_file('/etc/defaultdomain').with({
          'ensure' => 'file',
          'path'   => '/etc/defaultdomain',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
      }

      it {
        should contain_exec('domainname').with({
          'command'     => 'domainname example.com',
          'path'        => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin'],
          'refreshonly' => 'true',
          'notify'      => 'Service[nis_service]',
        })
      }

      it { should contain_file('/etc/defaultdomain').with_content(/^example.com\n$/) }

      it {
        should contain_service('nis_service').with({
          'ensure' => 'running',
          'name'   => 'nis/client',
          'enable' => 'true',
        })
      }
    end

    context 'with defaults params on Solaris 5.11' do
      let :facts do
        {
          :domain        => 'example.com',
          :kernel        => 'SunOS',
          :osfamily      => 'Solaris',
          :kernelrelease => '5.11',
        }
      end

      it { should_not contain_class('rpcbind') }

      it {
        should contain_package('system/network/nis').with({
          'ensure' => 'installed',
        })
      }

      it {
        should contain_file('/var/yp').with({
          'ensure' => 'directory',
          'path'   => '/var/yp',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
        })
      }

      it {
        should contain_file('/var/yp/binding').with({
          'ensure' => 'directory',
          'path'   => '/var/yp/binding',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
        })
      }

      it {
        should contain_file('/var/yp/binding/example.com').with({
          'ensure' => 'directory',
          'path'   => '/var/yp/binding/example.com',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
        })
      }

      it {
        should contain_file('/var/yp/binding/example.com/ypservers').with({
          'ensure'  => 'file',
          'path'    => '/var/yp/binding/example.com/ypservers',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'File[/var/yp/binding/example.com]',
          'notify'  => 'Exec[domainname]',
        })
      }

      it { should contain_file('/var/yp/binding/example.com/ypservers').with_content(/^127.0.0.1\n$/) }

      it {
        should contain_file('/etc/defaultdomain').with({
          'ensure' => 'file',
          'path'   => '/etc/defaultdomain',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
      }

      it {
        should contain_exec('domainname').with({
          'command'     => 'domainname example.com',
          'path'        => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin'],
          'refreshonly' => 'true',
          'notify'      => 'Service[nis_service]',
        })
      }

      it { should contain_file('/etc/defaultdomain').with_content(/^example.com\n$/) }

      it {
        should contain_service('nis_service').with({
          'ensure' => 'running',
          'name'   => 'nis/client',
          'enable' => 'true',
        })
      }
    end

    context 'with defaults params on Solaris 5.12' do
      let :facts do
        {
          :domain        => 'example.com',
          :kernel        => 'SunOS',
          :osfamily      => 'Solaris',
          :kernelrelease => '5.12',
        }
      end

      it 'should fail' do
        expect {
          should contain_class('nisclient')
        }.to raise_error(Puppet::Error,/nisclient supports SunOS 5\.10 and 5\.11\. Detected kernelrelease is <5\.12>\./)
      end

    end

    context 'with server parameter specified on Linux' do
      let :facts do
        {
          :domain            => 'example.com',
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end
      let :params do
        { :server => '192.168.1.1' }
      end

      it {
        should contain_file('/etc/yp.conf').with({
          'ensure' => 'file',
          'path'   => '/etc/yp.conf',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0644',
        })
      }

      it { should contain_file('/etc/yp.conf').with_content(/^# This file is being maintained by Puppet.\n# DO NOT EDIT\ndomain example.com server 192.168.1.1\n$/) }
    end

    context 'with server parameter specified on SunOS' do
      let :facts do
        {
          :domain        => 'example.com',
          :kernel        => 'SunOS',
          :osfamily      => 'Solaris',
          :kernelrelease => '5.10',
        }
      end
      let :params do
        { :server => '192.168.1.1' }
      end

      it {
        should contain_file('/var/yp/binding/example.com/ypservers').with({
          'ensure'  => 'file',
          'path'    => '/var/yp/binding/example.com/ypservers',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'require' => 'File[/var/yp/binding/example.com]',
          'notify'  => 'Exec[domainname]',
        })
      }

      it { should contain_file('/var/yp/binding/example.com/ypservers').with_content(/^192.168.1.1\n$/) }
    end

    context 'with package_ensure parameter specified' do
      let(:params) { { :package_ensure => 'absent' } }
      let :facts do
        {
          :domain            => 'example.com',
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end

      it {
        should contain_package('ypbind').with({
          'ensure' => 'absent',
        })
      }
    end

    context 'with package_name parameter specified' do
      let(:params) { { :package_name => 'mynispackage' } }
      let :facts do
        {
          :domain        => 'example.com',
          :kernel        => 'SunOS',
          :osfamily      => 'Solaris',
          :kernelrelease => '5.10',
        }
      end

      it {
        should contain_package('mynispackage').with({
          'ensure' => 'installed',
        })
      }
    end

    context 'with service_ensure parameter specified' do
      let(:params) { { :service_ensure => 'stopped' } }
      let :facts do
        {
          :domain            => 'example.com',
          :kernel            => 'Linux',
          :osfamily          => 'RedHat',
          :lsbmajdistrelease => '6',
        }
      end

      it {
        should contain_service('nis_service').with({
          'ensure' => 'stopped',
          'name'   => 'ypbind',
          'enable' => 'false',
        })
      }
    end

    context 'with service_name parameter specified' do
      let(:params) { { :service_name => 'mynisservice' } }
      let :facts do
        {
          :domain        => 'example.com',
          :kernel        => 'SunOS',
          :osfamily      => 'Solaris',
          :kernelrelease => '5.10',
        }
      end

      it {
        should contain_service('nis_service').with({
          'ensure' => 'running',
          'name'   => 'mynisservice',
          'enable' => 'true',
        })
      }
    end
  end
end
