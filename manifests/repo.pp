# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include gcsv5::repo
class gcsv5::repo {
  include epel

  exec { 'RPM-GPG-KEY-Globus':
    path    => '/usr/bin:/bin:/usr/sbin:/sbin',
    command => "wget -qO- ${gcsv5::release_url} | rpm2cpio - | cpio -i --quiet --to-stdout ./etc/pki/rpm-gpg/RPM-GPG-KEY-Globus > /etc/pki/rpm-gpg/RPM-GPG-KEY-Globus",
    creates => '/etc/pki/rpm-gpg/RPM-GPG-KEY-Globus',
    before  => Yumrepo['Globus-Toolkit']
  }

  yumrepo { 'Globus-Toolkit':
    descr          => 'Globus-Toolkit-6',
    baseurl        => $gcsv5::repo_baseurl,
    failovermethod => 'priority',
    priority       => '98',
    enabled        => '1',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Globus',
  }

  yumrepo { 'Globus-Toolkit-6-Testing':
    descr          => 'Globus-Toolkit-6-testing',
    baseurl        => $gcsv5::repo_testing_baseurl,
    failovermethod => 'priority',
    priority       => '98',
    enabled        => '0',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Globus',
  }

  yumrepo { 'globus-connect-server-5':
    descr          => 'Globus-Connect-Server-5',
    baseurl        => $gcsv5::repo_baseurl_v5,
    failovermethod => 'priority',
    priority       => '98',
    enabled        => '1',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Globus',
    require        => Exec['RPM-GPG-KEY-Globus'],
  }

  yumrepo { 'globus-connect-server-5-testing':
    descr          => 'Globus-Connect-Server-5-Testing',
    baseurl        => $gcsv5::repo_testing_baseurl_v5,
    failovermethod => 'priority',
    priority       => '98',
    enabled        => '0',
    gpgcheck       => '1',
    gpgkey         => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Globus',
    require        => Exec['RPM-GPG-KEY-Globus'],
  }

}
