package { 'ssl-cert':
  ensure => present,
}

package { 'python-setuptools':
  ensure => present,
} -> exec { 'install pip using easy_install':
  command => 'easy_install -U pip',
  path    => '/bin:/usr/bin:/usr/local/bin'
}

package { 'software-properties-common':
  ensure => present,
}
