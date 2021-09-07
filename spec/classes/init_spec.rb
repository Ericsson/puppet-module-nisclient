require 'spec_helper'
describe 'nisclient' do
  describe 'with default values for parameters' do
    content_yp_conf = <<-END.gsub(%r{^\s+\|}, '')
      |# This file is being maintained by Puppet.
      |# DO NOT EDIT
      |domain example.com server 127.0.0.1
    END

    # By default rspec-puppet-facts only provide facts for x86_64 architectures.
    # To be able to test Solaris we need to add 'i86pc' hardwaremodel.
    test_on = {
      hardwaremodels: ['x86_64', 'i386', 'i86pc']
    }

    on_supported_os(test_on).sort.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts }

        it { is_expected.to compile.with_all_deps }

        # OS specific defaults
        case os_facts[:osfamily]
        when 'RedHat', 'Suse'
          default_packages = 'ypbind'
          default_service  = 'ypbind'
        when 'Debian'
          default_packages = 'nis'
          default_service = case os_facts[:operatingsystemmajrelease]
                            when '16.04', '18.04'
                              'nis'
                            else
                              'ypbind'
                            end
        when 'Solaris'
          default_packages = case os_facts[:kernelrelease]
                             when '5.10'
                               [ 'SUNWnisr', 'SUNWnisu' ]
                             else
                               [ 'system/network/nis' ]
                             end

          default_service = 'nis/client'
        end

        case "#{os_facts[:osfamily]}#{os_facts[:operatingsystemmajrelease]}"
        # FIXME: verify that RedHat 8 doesn't need rpcbind
        when %r{Debian}, %r{RedHat(6|7)}, %r{Suse}
          it { is_expected.to contain_class('rpcbind') }
        else
          it { is_expected.not_to contain_class('rpcbind') }
        end

        if default_packages.class == String
          it { is_expected.to contain_package(default_packages).with_ensure('installed') }
        else
          default_packages.each do |package|
            it { is_expected.to contain_package(package).with_ensure('installed') }
          end
        end

        it {
          is_expected.to contain_service('nis_service').with(
            {
              'ensure' => 'running',
              'name'   => default_service,
              'enable' => true,
            },
          )
        }

        if os_facts[:osfamily] == 'Solaris'
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
                'content' => "127.0.0.1\n",
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

        else # Linux specific
          it {
            is_expected.to contain_file('/etc/yp.conf').with(
              {
                'ensure'  => 'file',
                'path'    => '/etc/yp.conf',
                'owner'   => 'root',
                'group'   => 'root',
                'mode'    => '0644',
                'require' => "Package[#{default_packages}]",
                'notify'  => 'Exec[ypdomainname]',
                'content' => content_yp_conf,
              },
            )
          }

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

          if os_facts[:osfamily] == 'RedHat'
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
          end
        end

        case os_facts[:osfamily]
        when 'Debian', 'Solaris', 'Suse'
          it {
            is_expected.to contain_file('/etc/defaultdomain').with(
              {
                'ensure'  => 'file',
                'path'    => '/etc/defaultdomain',
                'owner'   => 'root',
                'group'   => 'root',
                'mode'    => '0644',
                'content' => "example.com\n",
              },
            )
          }
        end

        # test parameter functionality
        context 'with domainname parameter set to valid value test.ing' do
          let(:params) { { domainname: 'test.ing' } }

          if os_facts[:osfamily] == 'RedHat'
            it { is_expected.to contain_exec('set_nisdomain').with_command('echo NISDOMAIN=test.ing >> /etc/sysconfig/network') }
            it {
              is_expected.to contain_exec('change_nisdomain').with(
                {
                  'command' => 'sed -i \'s/^NISDOMAIN.*/NISDOMAIN=test.ing/\' /etc/sysconfig/network',
                  'unless'  => 'grep ^NISDOMAIN=test.ing /etc/sysconfig/network',
                },
              )
            }
          elsif os_facts[:osfamily] == 'Solaris'
            it { is_expected.to contain_file('/var/yp/binding/test.ing') }
            it { is_expected.to contain_file('/var/yp/binding/test.ing/ypservers').with_require('File[/var/yp/binding/test.ing]') }
            it { is_expected.to contain_exec('domainname').with_command('domainname test.ing') }
          end

          case os_facts[:osfamily]
          when 'RedHat', 'Debian', 'Suse'
            it { is_expected.to contain_exec('ypdomainname').with_command('ypdomainname test.ing') }
          end

          case os_facts[:osfamily]
          when 'Debian', 'Solaris', 'Suse'
            it { is_expected.to contain_file('/etc/defaultdomain').with_content("test.ing\n") }
          end
        end

        context 'with server parameter set to valid value 127.0.0.242' do
          let(:params) { { server: '127.0.0.242' } }

          if os_facts[:osfamily] == 'Solaris'
            it { is_expected.to contain_file('/var/yp/binding/example.com/ypservers').with_content("127.0.0.242\n") }
          else # Linuxes
            content_yp_conf_server = <<-END.gsub(%r{^\s+\|}, '')
              |# This file is being maintained by Puppet.
              |# DO NOT EDIT
              |domain example.com server 127.0.0.242
            END

            it { is_expected.to contain_file('/etc/yp.conf').with_content(content_yp_conf_server) }
          end
        end

        context 'with broadcast parameter set to valid value <true>' do
          let(:params) { { broadcast: true } }

          if os_facts[:osfamily] != 'Solaris' # Linuxes
            content_yp_conf_broadcast = <<-END.gsub(%r{^\s+\|}, '')
              |# This file is being maintained by Puppet.
              |# DO NOT EDIT
              |domain example.com broadcast
            END

            it { is_expected.to contain_file('/etc/yp.conf').with_content(content_yp_conf_broadcast) }
          end
        end

        context 'with package_ensure parameter set to valid value absent' do
          let(:params) { { package_ensure: 'absent' } }

          if default_packages.class == String
            it { is_expected.to contain_package(default_packages).with_ensure('absent') }
          else
            default_packages.each do |package|
              it { is_expected.to contain_package(package).with_ensure('absent') }
            end
          end
        end

        context 'with package_name parameter set to valid value [test ing]' do
          let(:params) { { package_name: [ 'test', 'ing' ] } }

          [ 'test', 'ing' ].each do |package|
            it { is_expected.to contain_package(package).with_ensure('installed') }
          end

          if os_facts[:osfamily] != 'Solaris' # Linuxes
            it { is_expected.to contain_file('/etc/yp.conf').with_require(['Package[test]', 'Package[ing]']) }
          end
        end

        context 'with service_ensure parameter set to valid value stopped' do
          let(:params) { { service_ensure: 'stopped' } }

          it {
            is_expected.to contain_service('nis_service').with(
              {
                'ensure' => 'stopped',
                'enable' => false,
              },
            )
          }
        end

        context 'with service_name parameter set to valid value test' do
          let(:params) { { service_name: 'test' } }

          it { is_expected.to contain_service('nis_service').with_name('test') }
        end
      end
    end
  end
end
