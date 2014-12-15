# == Class: hiera::eyaml
#
# This class installs and configures hiera-eyaml
#
# === Authors:
#
# Terri Haber <terri@puppetlabs.com>
#
# === Copyright:
#
# Copyright (C) 2014 Terri Haber, unless otherwise noted.
#
class hiera::eyaml (
  $provider  = $hiera::params::provider,
  $owner     = $hiera::owner,
  $group     = $hiera::group,
  $cmdpath   = $hiera::cmdpath,
  $confdir   = $hiera::confdir,
  $eyaml_gpg = $hiera::eyaml_gpg,
) inherits hiera::params {

  package { 'hiera-eyaml':
    ensure   => installed,
    provider => $provider,
  }

  file { "${confdir}/keys":
    ensure => directory,
    owner  => $owner,
    group  => $group,
    before => Exec['createkeys'],
  }

  # Removing the hiera-eyaml-gpg gem if its installed and we need to generate keys
  # There is a bug where it wont allow puppet to run eyaml createkeys if both are installed
  exec { 'remove_hiera_eyaml_gpg':
    command => 'gem uninstall hiera-eyaml-gpg',
    onlyif  => 'gem list hiera-eyaml-gpg -i > /dev/null',
    path    => $cmdpath,
    creates => "${confdir}/keys/private_key.pkcs7.pem",
    require => Package['hiera-eyaml'],
    before  => Exec['createkeys'],
  }

  exec { 'createkeys':
    user    => $owner,
    cwd     => $confdir,
    command => 'eyaml createkeys',
    path    => $cmdpath,
    creates => "${confdir}/keys/private_key.pkcs7.pem",
    require => Package['hiera-eyaml'],
  }


  file { "${confdir}/keys/private_key.pkcs7.pem":
    ensure  => file,
    mode    => '0600',
    owner   => $owner,
    group   => $group,
    require => Exec['createkeys'],
  }

  file { "${confdir}/keys/public_key.pkcs7.pem":
    ensure  => file,
    mode    => '0644',
    owner   => $owner,
    group   => $group,
    require => Exec['createkeys'],
  }
}
