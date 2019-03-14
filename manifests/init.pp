# Copyright 2015 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# == Class: diskimage_builder
#
class diskimage_builder (
  $git_source_repo = 'git+https://git.openstack.org/openstack/diskimage-builder',
  $use_git         = false,
  $support_vhd     = true,
  ) {
  include ::pip

  if $support_vhd {
    file { '/root/openstack-ci-core-ppa-key.pubkey':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => 0644,
      source => 'puppet:///modules/diskimage_builder/openstack-ci-core-ppa-key.pubkey',
    }
    include ::apt
    apt::key { 'openstack-ci-core-ppa-key':
      id      => '15B6CE7C018D05F5',
      source  => '/root/openstack-ci-core-ppa-key.pubkey',
      require => File['/root/openstack-ci-core-ppa-key.pubkey'],
    }
    apt::ppa { 'ppa:openstack-ci-core/vhd-util':
      require => Apt::Key['openstack-ci-core-ppa-key'],
    }
    package { 'vhd-util':
      ensure  => present,
      require => [
        Apt::Ppa['ppa:openstack-ci-core/vhd-util'],
        Class['apt::update'],
      ],
    }
  }

  $packages = [
    'debian-keyring',
    'debootstrap',
    'kpartx',
    'python-lzma',
    'qemu-utils',
    'ubuntu-keyring',
    'yum',
    'yum-utils',
  ]

  # Ubuntu trusty doesn't support zypper today, so skip it.
  if ($::lsbdistcodename != 'trusty') {
    # gnupg2 is a missing dependency on zypper, see
    # https://bugs.launchpad.net/bugs/1639428
    package { ['zypper', 'gnupg2']:
      ensure => present,
    }
  }

  package { $packages:
    ensure  => present,
  }

  # required by lvm dib element
  if ! defined(Package['lvm2']) {
      package { 'lvm2':
          ensure => present,
      }
  }


  if $use_git == true {
    package { 'diskimage-builder':
      ensure   => present,
      provider => openstack_pip,
      source   => $git_source_repo,
      require  => [
        Class['pip'],
      ],
    }
  }
  else {
    package { 'diskimage-builder':
      ensure   => latest,
      provider => openstack_pip,
      require  => [
        Class['pip'],
      ],
    }
  }
}
