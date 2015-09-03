require 'spec_helper_acceptance'

describe 'packages' do
  describe 'required OS packages' do
    required_packages = [
      package('debian-keyring'),
      package('debootstrap'),
      package('kpartx'),
      package('python-lzma'),
      package('python-yaml'),
      package('qemu-utils'),
      package('ubuntu-keyring'),
      package('vhd-util'),
      package('yum'),
      package('yum-utils'),
    ]

    required_packages.each do |package|
      describe package do
        it { should be_installed }
      end
    end
  end

  describe 'required Python packages' do
    describe package('diskimage-builder') do
      it { should be_installed.by('pip') }
    end
  end

  describe ppa('openstack-ci-core/vhd-util') do
    it { should exist }
    it { should be_enabled }
  end
end
