require 'spec_helper'
describe 'nisclient' do
  describe 'on kernel Linux' do
    context 'with default params on EL 5' do
      let :facts do
        {
          domain: 'example.com',
          kernel: 'Linux',
          osfamily: 'RedHat',
          operatingsystemmajrelease: '5',
          os: {
            'family' => 'RedHat',
            'name' => 'RedHat',
            'release': { 'major' => '5' },
          },
        }
      end

      it { is_expected.not_to contain_class('rpcbind') }

      it { is_expected.to contain_package('ypbind').with_ensure('installed') }

      it {
        is_expected.to contain_file('/etc/yp.conf').with(
          {
            'ensure'  => 'file',
            'path'    => '/etc/yp.conf',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => 'Package[ypbind]',
            'notify'  => 'Exec[ypdomainname]',
          },
        )
      }

      it { is_expected.to contain_file('/etc/yp.conf').with_content(%r{^# This file is being maintained by Puppet.\n# DO NOT EDIT\ndomain example.com server 127.0.0.1\n$}) }

      it {
        is_expected.to contain_exec('ypdomainname').with(
          {
            'command'     => 'ypdomainname example.com',
            'path'        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
            'refreshonly' => 'true',
            'notify'      => 'Service[nis_service]',
          },
        )
      }

      it {
        is_expected.to contain_exec('set_nisdomain').with(
          {
            'command' => 'echo NISDOMAIN=example.com >> /etc/sysconfig/network',
            'path'    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
            'unless'  => 'grep ^NISDOMAIN /etc/sysconfig/network',
          },
        )
      }

      it {
        is_expected.to contain_exec('change_nisdomain').with(
          {
            'command' => 'sed -i \'s/^NISDOMAIN.*/NISDOMAIN=example.com/\' /etc/sysconfig/network',
            'path'    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
            'unless'  => 'grep ^NISDOMAIN=example.com /etc/sysconfig/network',
            'onlyif'  => 'grep ^NISDOMAIN /etc/sysconfig/network',
          },
        )
      }

      it {
        is_expected.to contain_service('nis_service').with(
          {
            'ensure' => 'running',
            'name'   => 'ypbind',
            'enable' => 'true',
          },
        )
      }
    end

    context 'with default params on EL 6' do
      let :facts do
        {
          domain:                    'example.com',
          kernel:                    'Linux',
          osfamily:                  'RedHat',
          operatingsystemmajrelease: '6',
          os: {
            'family' => 'RedHat',
            'name' => 'RedHat',
          'release': { 'major' => '6' },
          },
        }
      end

      it { is_expected.to contain_class('rpcbind') }

      it { is_expected.to contain_package('ypbind').with_ensure('installed') }

      it {
        is_expected.to contain_file('/etc/yp.conf').with(
          {
            'ensure' => 'file',
            'path'   => '/etc/yp.conf',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
            'require' => 'Package[ypbind]',
            'notify'  => 'Exec[ypdomainname]',
          },
        )
      }

      it { is_expected.to contain_file('/etc/yp.conf').with_content(%r{^# This file is being maintained by Puppet.\n# DO NOT EDIT\ndomain example.com server 127.0.0.1\n$}) }

      it {
        is_expected.to contain_exec('ypdomainname').with(
          {
            'command'     => 'ypdomainname example.com',
            'path'        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
            'refreshonly' => 'true',
            'notify'      => 'Service[nis_service]',
          },
        )
      }

      it {
        is_expected.to contain_exec('set_nisdomain').with(
          {
            'command' => 'echo NISDOMAIN=example.com >> /etc/sysconfig/network',
            'path'    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
            'unless'  => 'grep ^NISDOMAIN /etc/sysconfig/network',
          },
        )
      }

      it {
        is_expected.to contain_exec('change_nisdomain').with(
          {
            'command' => 'sed -i \'s/^NISDOMAIN.*/NISDOMAIN=example.com/\' /etc/sysconfig/network',
            'path'    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
            'unless'  => 'grep ^NISDOMAIN=example.com /etc/sysconfig/network',
            'onlyif'  => 'grep ^NISDOMAIN /etc/sysconfig/network',
          },
        )
      }

      it {
        is_expected.to contain_service('nis_service').with(
          {
            'ensure' => 'running',
            'name'   => 'ypbind',
            'enable' => 'true',
          },
        )
      }
    end

    context 'with default params on Suse' do
      let :facts do
        {
          domain:   'example.com',
          kernel:   'Linux',
          osfamily: 'Suse',
          os: {
            'family' => 'Suse',
            'name' => 'Suse',
            'release': { 'major' => '15' },
          },
        }
      end

      it { is_expected.to contain_class('rpcbind') }

      it { is_expected.to contain_package('ypbind').with_ensure('installed') }

      it {
        is_expected.to contain_file('/etc/yp.conf').with(
          {
            'ensure' => 'file',
            'path'   => '/etc/yp.conf',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
            'require' => 'Package[ypbind]',
            'notify'  => 'Exec[ypdomainname]',
          },
        )
      }

      it { is_expected.to contain_file('/etc/yp.conf').with_content(%r{^# This file is being maintained by Puppet.\n# DO NOT EDIT\ndomain example.com server 127.0.0.1\n$}) }

      it {
        is_expected.to contain_exec('ypdomainname').with(
          {
            'command'     => 'ypdomainname example.com',
            'path'        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
            'refreshonly' => 'true',
            'notify'      => 'Service[nis_service]',
          },
        )
      }

      it {
        is_expected.to contain_file('/etc/defaultdomain').with(
          {
            'ensure' => 'file',
            'path'   => '/etc/defaultdomain',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          },
        )
      }

      it { is_expected.to contain_file('/etc/defaultdomain').with_content(%r{^example.com\n$}) }

      it {
        is_expected.to contain_service('nis_service').with(
          {
            'ensure' => 'running',
            'name'   => 'ypbind',
            'enable' => 'true',
          },
        )
      }
    end

    context 'with defaults params on Ubuntu 18.04' do
      let :facts do
        {
          domain:                 'example.com',
          kernel:                 'Linux',
          lsbdistid:              'Ubuntu', # needed for rpcbind module dependency
          osfamily:               'Debian',
          operatingsystemrelease: '18.04',
          os: {
            'family' => 'Debian',
            'name' => 'Debian',
            'release': { 'major' => '18.04' },
          },
        }
      end

      it { is_expected.to contain_class('rpcbind') }

      it { is_expected.to contain_package('nis').with_ensure('installed') }

      it {
        is_expected.to contain_file('/etc/yp.conf').with(
          {
            'ensure' => 'file',
            'path'   => '/etc/yp.conf',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
            'require' => 'Package[nis]',
            'notify'  => 'Exec[ypdomainname]',
          },
        )
      }

      it { is_expected.to contain_file('/etc/yp.conf').with_content(%r{^# This file is being maintained by Puppet.\n# DO NOT EDIT\ndomain example.com server 127.0.0.1\n$}) }

      it {
        is_expected.to contain_exec('ypdomainname').with(
          {
            'command'     => 'ypdomainname example.com',
            'path'        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
            'refreshonly' => 'true',
            'notify'      => 'Service[nis_service]',
          },
        )
      }

      it {
        is_expected.to contain_file('/etc/defaultdomain').with(
          {
            'ensure' => 'file',
            'path'   => '/etc/defaultdomain',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          },
        )
      }

      it { is_expected.to contain_file('/etc/defaultdomain').with_content(%r{^example.com\n$}) }

      it {
        is_expected.to contain_service('nis_service').with(
          {
            'ensure' => 'running',
            'name'   => 'nis',
            'enable' => 'true',
          },
        )
      }

      context 'with version 14.04' do
        let :facts do
          {
            domain:                 'example.com',
            kernel:                 'Linux',
            lsbdistid:              'Ubuntu', # needed for rpcbind module dependency
            osfamily:               'Debian',
            operatingsystemrelease: '14.04',
            os: {
              'family' => 'Debian',
              'name' => 'Debian',
              'release': { 'major' => '14.04' },
            },
          }
        end

        it {
          is_expected.to contain_service('nis_service').with(
            {
              'ensure' => 'running',
              'name'   => 'ypbind',
              'enable' => 'true',
            },
          )
        }
      end

      context 'with version 16.04' do
        let :facts do
          {
            domain:                 'example.com',
            kernel:                 'Linux',
            lsbdistid:              'Ubuntu', # needed for rpcbind module dependency
            osfamily:               'Debian',
            operatingsystemrelease: '16.04',
            os: {
              'family' => 'Debian',
              'name' => 'Debian',
              'release': { 'major' => '16.04' },
            },
          }
        end

        it {
          is_expected.to contain_service('nis_service').with(
            {
              'ensure' => 'running',
              'name'   => 'nis',
              'enable' => 'true',
            },
          )
        }
      end
    end

    context 'with defaults params on unsupported osfamily' do
      let :facts do
        {
          domain:   'example.com',
          kernel:   'Linux',
          osfamily: 'Unsupported',
          os: {
            'family' => 'unsupported',
            'name' => 'unsupported',
            'release': { 'major' => '0' },
          },
        }
      end

      it 'fail' do
        expect {
          is_expected.to contain_class('nisclient')
        }.to raise_error(Puppet::Error, %r{nisclient supports osfamilies Debian, RedHat, and Suse on the Linux kernel. Detected osfamily is <Unsupported>.})
      end
    end
  end

  describe 'with parameter broadcast' do
    ['true', true].each do |value|
      context "set to #{value}" do
        let :facts do
          {
            domain:                    'example.com',
            kernel:                    'Linux',
            osfamily:                  'RedHat',
            operatingsystemmajrelease: '6',
            os: {
              'family' => 'RedHat',
              'name' => 'RedHat',
              'release': { 'major' => '6' },
            },
          }
        end

        let :params do
          {
            broadcast: value,
          }
        end

        it { is_expected.to contain_file('/etc/yp.conf').with_content(%r{^domain example\.com broadcast$}) }
      end
    end

    ['false', false].each do |value|
      context "set to #{value}" do
        let :facts do
          {
            domain:                    'example.com',
            kernel:                    'Linux',
            osfamily:                  'RedHat',
            operatingsystemmajrelease: '6',
            os: {
              'family' => 'RedHat',
              'name' => 'RedHat',
              'release': { 'major' => '6' },
            },
          }
        end

        let :params do
          {
            broadcast: value,
          }
        end

        it { is_expected.to contain_file('/etc/yp.conf').with_content(%r{^domain example\.com server 127\.0\.0\.1$}) }
      end
    end

    context 'set to an invalid value' do
      let :facts do
        {
          domain:        'example.com',
          kernel:        'Linux',
          osfamily:      'RedHat',
          os: {
            'family' => 'RedHat',
            'name' => 'RedHat',
            'release': { 'major' => '6' },
          },
        }
      end

      let :params do
        {
          broadcast: 'invalid',
        }
      end

      it 'fail' do
        expect {
          is_expected.to contain_class('nisclient')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  describe 'on kernel SunOS' do
    context 'with defaults params on Solaris 5.10' do
      let :facts do
        {
          domain:        'example.com',
          kernel:        'SunOS',
          osfamily:      'Solaris',
          kernelrelease: '5.10',
          os: {
            'family' => 'Solaris',
            'name' => 'Solaris',
            'release': { 'major' => '10' },
          },
        }
      end

      it { is_expected.not_to contain_class('rpcbind') }

      it { is_expected.to contain_package('SUNWnisr').with_ensure('installed') }

      it { is_expected.to contain_package('SUNWnisu').with_ensure('installed') }

      it {
        is_expected.to contain_file('/var/yp').with(
          {
            'ensure' => 'directory',
            'path'   => '/var/yp',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          },
        )
      }

      it {
        is_expected.to contain_file('/var/yp/binding').with(
          {
            'ensure' => 'directory',
            'path'   => '/var/yp/binding',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          },
        )
      }

      it {
        is_expected.to contain_file('/var/yp/binding/example.com').with(
          {
            'ensure' => 'directory',
            'path'   => '/var/yp/binding/example.com',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          },
        )
      }

      it {
        is_expected.to contain_file('/var/yp/binding/example.com/ypservers').with(
          {
            'ensure'  => 'file',
            'path'    => '/var/yp/binding/example.com/ypservers',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => 'File[/var/yp/binding/example.com]',
            'notify'  => 'Exec[domainname]',
          },
        )
      }

      it { is_expected.to contain_file('/var/yp/binding/example.com/ypservers').with_content(%r{^127.0.0.1\n$}) }

      it {
        is_expected.to contain_file('/etc/defaultdomain').with(
          {
            'ensure' => 'file',
            'path'   => '/etc/defaultdomain',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          },
        )
      }

      it {
        is_expected.to contain_exec('domainname').with(
          {
            'command'     => 'domainname example.com',
            'path'        => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin'],
            'refreshonly' => 'true',
            'notify'      => 'Service[nis_service]',
          },
        )
      }

      it { is_expected.to contain_file('/etc/defaultdomain').with_content(%r{^example.com\n$}) }

      it {
        is_expected.to contain_service('nis_service').with(
          {
            'ensure' => 'running',
            'name'   => 'nis/client',
            'enable' => 'true',
          },
        )
      }
    end

    context 'with defaults params on Solaris 5.11' do
      let :facts do
        {
          domain:        'example.com',
          kernel:        'SunOS',
          osfamily:      'Solaris',
          kernelrelease: '5.11',
          os: {
            'family' => 'Solaris',
            'name' => 'Solaris',
            'release': { 'major' => '11' },
          },
        }
      end

      it { is_expected.not_to contain_class('rpcbind') }

      it { is_expected.to contain_package('system/network/nis').with_ensure('installed') }

      it {
        is_expected.to contain_file('/var/yp').with(
          {
            'ensure' => 'directory',
            'path'   => '/var/yp',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          },
        )
      }

      it {
        is_expected.to contain_file('/var/yp/binding').with(
          {
            'ensure' => 'directory',
            'path'   => '/var/yp/binding',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          },
        )
      }

      it {
        is_expected.to contain_file('/var/yp/binding/example.com').with(
          {
            'ensure' => 'directory',
            'path'   => '/var/yp/binding/example.com',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          },
        )
      }

      it {
        is_expected.to contain_file('/var/yp/binding/example.com/ypservers').with(
          {
            'ensure'  => 'file',
            'path'    => '/var/yp/binding/example.com/ypservers',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => 'File[/var/yp/binding/example.com]',
            'notify'  => 'Exec[domainname]',
          },
        )
      }

      it { is_expected.to contain_file('/var/yp/binding/example.com/ypservers').with_content(%r{^127.0.0.1\n$}) }

      it {
        is_expected.to contain_file('/etc/defaultdomain').with(
          {
            'ensure' => 'file',
            'path'   => '/etc/defaultdomain',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          },
        )
      }

      it {
        is_expected.to contain_exec('domainname').with(
          {
            'command'     => 'domainname example.com',
            'path'        => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin'],
            'refreshonly' => 'true',
            'notify'      => 'Service[nis_service]',
          },
        )
      }

      it { is_expected.to contain_file('/etc/defaultdomain').with_content(%r{^example.com\n$}) }

      it {
        is_expected.to contain_service('nis_service').with(
          {
            'ensure' => 'running',
            'name'   => 'nis/client',
            'enable' => 'true',
          },
        )
      }
    end

    context 'with defaults params on Solaris 5.12' do
      let :facts do
        {
          domain:        'example.com',
          kernel:        'SunOS',
          osfamily:      'Solaris',
          kernelrelease: '5.12',
          os: {
            'family' => 'Solaris',
            'name' => 'Solaris',
            'release': { 'major' => '12' },
          },
        }
      end

      it 'fail' do
        expect {
          is_expected.to contain_class('nisclient')
        }.to raise_error(Puppet::Error, %r{nisclient supports SunOS 5\.10 and 5\.11\. Detected kernelrelease is <5\.12>\.})
      end
    end

    context 'with server parameter specified on Linux' do
      let :facts do
        {
          domain:                    'example.com',
          kernel:                    'Linux',
          osfamily:                  'RedHat',
          operatingsystemmajrelease: '6',
          os: {
            'family' => 'RedHat',
            'name' => 'RedHat',
            'release': { 'major' => '6' },
          },
        }
      end
      let :params do
        { server: '192.168.1.1' }
      end

      it {
        is_expected.to contain_file('/etc/yp.conf').with(
          {
            'ensure' => 'file',
            'path'   => '/etc/yp.conf',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          },
        )
      }

      it { is_expected.to contain_file('/etc/yp.conf').with_content(%r{^# This file is being maintained by Puppet.\n# DO NOT EDIT\ndomain example.com server 192.168.1.1\n$}) }
    end

    context 'with server parameter specified on SunOS' do
      let :facts do
        {
          domain:        'example.com',
          kernel:        'SunOS',
          osfamily:      'Solaris',
          kernelrelease: '5.10',
          os: {
            'family' => 'Solaris',
            'name' => 'Solaris',
            'release': { 'major' => '10' },
          },
        }
      end
      let :params do
        { server: '192.168.1.1' }
      end

      it {
        is_expected.to contain_file('/var/yp/binding/example.com/ypservers').with(
          {
            'ensure'  => 'file',
            'path'    => '/var/yp/binding/example.com/ypservers',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'require' => 'File[/var/yp/binding/example.com]',
            'notify'  => 'Exec[domainname]',
          },
        )
      }

      it { is_expected.to contain_file('/var/yp/binding/example.com/ypservers').with_content(%r{^192.168.1.1\n$}) }
    end

    context 'with package_ensure parameter specified' do
      let(:params) { { package_ensure: 'absent' } }
      let :facts do
        {
          domain:                    'example.com',
          kernel:                    'Linux',
          osfamily:                  'RedHat',
          operatingsystemmajrelease: '6',
          os: {
            'family' => 'RedHat',
            'name' => 'RedHat',
            'release': { 'major' => '6' },
          },
        }
      end

      it { is_expected.to contain_package('ypbind').with_ensure('absent') }
    end

    context 'with package_name parameter specified' do
      let(:params) { { package_name: 'mynispackage' } }
      let :facts do
        {
          domain:        'example.com',
          kernel:        'SunOS',
          osfamily:      'Solaris',
          kernelrelease: '5.10',
          os: {
            'family' => 'Solaris',
            'name' => 'Solaris',
            'release': { 'major' => '10' },
          },
        }
      end

      it { is_expected.to contain_package('mynispackage').with_ensure('installed') }
    end

    context 'with service_ensure parameter specified' do
      let(:params) { { service_ensure: 'stopped' } }
      let :facts do
        {
          domain:                    'example.com',
          kernel:                    'Linux',
          osfamily:                  'RedHat',
          operatingsystemmajrelease: '6',
          os: {
            'family' => 'RedHat',
            'name' => 'RedHat',
            'release': { 'major' => '6' },
          },
        }
      end

      it {
        is_expected.to contain_service('nis_service').with(
          {
            'ensure' => 'stopped',
            'name'   => 'ypbind',
            'enable' => 'false',
          },
        )
      }
    end

    context 'with service_name parameter specified' do
      let(:params) { { service_name: 'mynisservice' } }
      let :facts do
        {
          domain:        'example.com',
          kernel:        'SunOS',
          osfamily:      'Solaris',
          kernelrelease: '5.10',
          os: {
            'family' => 'Solaris',
            'name' => 'Solaris',
            'release': { 'major' => '10' },
          },
        }
      end

      it {
        is_expected.to contain_service('nis_service').with(
          {
            'ensure' => 'running',
            'name'   => 'mynisservice',
            'enable' => 'true',
          },
        )
      }
    end
  end
end
