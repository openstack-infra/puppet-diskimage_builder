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
  $use_git = false,
  $git_source_repo = 'https://git.openstack.org/openstack/diskimage-builder',
  ) {
  include ::pip
  include ::apt

  $packages = [
    'debian-keyring',
    'debootstrap',
    'kpartx',
    'python-lzma',
    'qemu-utils',
    'ubuntu-keyring',
    'vhd-util',
    'yum',
    'yum-utils',
  ]

  apt::ppa { 'ppa:openstack-ci-core/vhd-util':
  }

  package { $packages:
    ensure  => present,
    require => [
      Apt::Ppa['ppa:openstack-ci-core/vhd-util'],
      Class['apt::update'],
    ],
  }

  # required by the diskimage-builder element scripts
  if ! defined(Package['python-yaml']) {
      package { 'python-yaml':
          ensure => present,
      }
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
      provider => pip,
      source   => $git_source_repo,
      require  => [
                   Class['pip'],
                   Package['python-yaml'],
                   ],
    }
  }
  else {
    package { 'diskimage-builder':
      ensure   => latest,
      provider => pip,
      require  => [
                   Class['pip'],
                   Package['python-yaml'],
                   ],
    }
  }
}
