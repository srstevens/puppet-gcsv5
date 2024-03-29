# @summary A short summary of the purpose of this class
#
# Manage gcsv5 configurations
#
# @example
#   include gcsv5::config
class gcsv5::config() {

    exec {'globus_conf directory':
        command  => "mkdir /root/globus_conf",
        cwd      => "/root",
        path     => '/bin:/usr/bin:/sbin:/usr/sbin',
        provider => "shell",
        unless   => "test -s \'${gcsv5::globus_info_file}\'",
    }

    exec {'gcsv5_deployment_key':
        command  =>  "cd $gcsv5::globus_conf && echo \'${gcsv5::deployment_key}\' > ${gcsv5::globus_conf}/deployment-key.json",
        path     =>  '/bin:/usr/bin:/sbin:/usr/sbin',
        provider =>  "shell",
        unless   =>  "test -s \'${gcsv5::globus_info_file}\'",
    }

    if ( ! empty($gcsv5::node_info) ) {
        exec {'gcsv5_node_info':
            command  =>  "cd $gcsv5::globus_conf && echo \'${gcsv5::node_info}\' > ${gcsv5::globus_conf}/node_info.json",
            path     =>  '/bin:/usr/bin:/sbin:/usr/sbin',
            provider =>  "shell",
            unless   =>  "test -s \'${gcsv5::globus_info_file}\'",
        }

        exec {'gcsv5_node_setup_import':
            command  => "cd $gcsv5::globus_conf && LC_ALL=en_US.utf8 ${gcsv5::gcs_cmd} node setup --import-node ./node_info.json --ip-address ${gcsv5::ip_addr} && cd /root && rm -rf $gcsv5::globus_conf",
            path     => '/bin:/usr/bin:/sbin:/usr/sbin',
            unless   => [ "if [[ `/usr/bin/ps -eaf|/usr/bin/grep gridftp|/usr/bin/grep -v grep |/usr/bin/wc -l` -gt 0 ]]; then exit 0; else exit 1;fi;", "test -s \'${gcsv5::globus_info_file}\'" ],
            provider => 'shell'
        }
    } else {
        exec {'gcsv5_node_setup':
            command  => "cd $gcsv5::globus_conf && ${gcsv5::gcs_cmd} node setup --ip-address ${gcsv5::ip_addr} --export-node ./node_info_new.json && rm -rf ./deployment-key.json",
            path     => '/bin:/usr/bin:/sbin:/usr/sbin',
            unless   => [ "if [[ `/usr/bin/ps -eaf|/usr/bin/grep gridftp|/usr/bin/grep -v grep |/usr/bin/wc -l` -gt 0 ]]; then exit 0; else exit 1;fi;", "test -s \'${gcsv5::globus_info_file}\'" ],
            provider => 'shell'
        }
    }

    service { 'globus-gridftp-server':
        ensure => 'running',
        enable => true,
    }

    file_line { 'gcs_loglevel':
        ensure => present,
        path   => '/etc/gridftp.d/globus-connect-server',
        line   => 'log_level ERROR,WARN,TRANSFER',
        match  => '^log_level ERROR,WARN$',
        notify => Service['globus-gridftp-server'],
    }

    service { 'httpd':
        ensure => 'running',
        enable => true,
    }

    file { '/etc/httpd/conf.d/000-security.conf':
        ensure => present,
        group  => root,
        mode   => '0644',
        notify => Service['httpd'],
        owner  => root,
        source => 'puppet:///modules/gcsv5/000-security.conf',
    }

    file { '/etc/httpd/conf.d/ssl.conf':
        ensure => present,
        group  => root,
        mode   => '0644',
        notify => Service['httpd'],
        owner  => root,
        source => 'puppet:///modules/gcsv5/ssl.conf',
    }

    file { '/etc/httpd/conf.d/welcome.conf':
        ensure => absent,
        notify => Service['httpd'],
    }

    file { '/etc/httpd/conf/httpd.conf':
        ensure => present,
        group  => root,
        mode   => '0644',
        notify => Service['httpd'],
        owner  => root,
        source => 'puppet:///modules/gcsv5/httpd.conf',
    }

}
