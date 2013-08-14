require 'spec_helper'
describe 'nisclient' do
  let :facts do
    { :kernel => 'Linux',
      :osfamily => 'RedHat'
    }
  end

  describe 'when using default values for class' do
    it {
      should contain_file('/etc/yp.conf').with({
        'ensure' => 'present',
        'path'   => '/etc/yp.conf',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('/etc/yp.conf').with_content(
%{domain example.com server 127.0.0.1\n})
    }
    it { 
      should contain_package('nis_package').with({
        'ensure' => 'installed',
        'name'   => 'ypbind',
      })
    }
  end

  describe 'when using default values for class on Suse' do
    let :facts do
      { :kernel   => 'Linux',
        :osfamily => 'Suse' }
    end
    it { 
      should contain_package('nis_package').with({
        'ensure' => 'installed',
        'name'   => 'ypbind',
      })
    }
  end
  
  describe 'when using default values for class on Ubuntu' do
    let :facts do
      { :kernel   => 'Linux',
        :osfamily => 'Debian' }
    end
    it { 
      should contain_package('nis_package').with({
        'ensure' => 'installed',
        'name'   => 'nis',
      })
    }
  end

  describe 'with parameter domainname set' do
    let :params do
      { :domainname => 'rnd.example.com' }
    end

    it {
      should contain_file('/etc/yp.conf').with({
        'ensure' => 'present',
        'path'   => '/etc/yp.conf',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('/etc/yp.conf').with_content(
%{domain rnd.example.com server 127.0.0.1\n})
    }
  end

  describe 'with parameter server set' do
    let :params do
      { :server => '192.168.1.1' }
    end

    it {
      should contain_file('/etc/yp.conf').with({
        'ensure' => 'present',
        'path'   => '/etc/yp.conf',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('/etc/yp.conf').with_content(
%{domain example.com server 192.168.1.1\n})
    }
  end
  describe 'with parameters server and domainname set on solaris' do
    let :params do
      { :server     => 'localhost',
        :domainname => 'rnd.example.com' }
    end
    let :facts do
      { :kernel   => 'SunOS',
        :osfamily => 'Solaris' }
    end

    it {
      should contain_file('/var/yp/binding/rnd.example.com/ypservers').with({
        'ensure' => 'present',
        'path'   => '/var/yp/binding/rnd.example.com/ypservers',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('/var/yp/binding/rnd.example.com/ypservers').with_content(
%{localhost\n})
    }
    it {
      should contain_file('/etc/defaultdomain').with({
        'ensure' => 'present',
        'path'   => '/etc/defaultdomain',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
      })
      should contain_file('/etc/defaultdomain').with_content(
%{rnd.example.com\n})
    }
  end
end

