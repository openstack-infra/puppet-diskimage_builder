require 'puppet-openstack_infra_spec_helper/spec_helper_acceptance'

describe 'puppet-diskimage_builder module', :if => ['debian', 'ubuntu'].include?(os[:family]) do
  def pp_path
    base_path = File.dirname(__FILE__)
    File.join(base_path, 'fixtures')
  end

  def preconditions_puppet_module
    module_path = File.join(pp_path, 'preconditions.pp')
    File.read(module_path)
  end

  def default_puppet_module
    module_path = File.join(pp_path, 'default.pp')
    File.read(module_path)
  end

  before(:all) do
    apply_manifest(preconditions_puppet_module, catch_failures: true)
  end

  it 'should work with no errors' do
    apply_manifest(default_puppet_module, catch_failures: true)
  end

  it 'should be idempotent' do
    apply_manifest(default_puppet_module, catch_changes: true)
  end

  describe 'packages' do
    describe 'required OS packages' do
      required_packages = [
        package('debian-keyring'),
        package('debootstrap'),
        package('kpartx'),
        package('python-lzma'),
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
end
