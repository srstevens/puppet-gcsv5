# @summary A short summary of the purpose of this class
#
# Manage gcsv5 configurations
#
# @example
#   include gcsv5::config
class gcsv5::config() {

    #Create files
    file { '/root/globus_conf':
        ensure => directory,
        group  => root,
        mode   => '0600',
        owner  => root,
    }

    exec {'gcsv5_deployment_key':
        command  =>  "echo $gcsv5::deployment_key > $gcsv5::globus_conf/deployment-key.json",
        cwd      =>  "$gcsv5::globus_conf"
        path     =>  '/bin:/usr/bin:/sbin:/usr/sbin',
        provider =>  "shell",
    }

    if ( ! empty($gcsv5::node_info) ) {
        file { '/root/globus_conf/node_info.json':
            content => $gcsv5::node_info,
            ensure  => file,
            group   => root,
            mode    => '0600',
            owner   => root,
        }

        exec {'gcsv5_node_info':
            command  =>  "echo $gcsv5::node_info > $gcsv5::globus_conf/node_info.json",
            cwd      =>  "$gcsv5::globus_conf"
            path     =>  '/bin:/usr/bin:/sbin:/usr/sbin',
            provider =>  "shell",
        }

        exec {'gcsv5_node_setup_import':
            command  => "LC_ALL=en_US.utf8 ${gcsv5::gcs_cmd} node setup --client-id ${gcsv5::client_id} --secret ${gcsv5::client_secret} --import-node ./node_info.json --ip-address ${gcsv5::ip_addr}",
            cwd      => '/root/globus_conf',
            path     => '/bin:/usr/bin:/sbin:/usr/sbin',
            unless   => "if [[ `/usr/bin/ps -eaf|/usr/bin/grep gridftp|/usr/bin/grep -v grep |/usr/bin/wc -l` -gt 0 ]]; then exit 0; else exit 1;fi;",
            provider => 'shell'
        }
    } else {
        exec {'gcsv5_node_setup':
            command  => "${gcsv5::gcs_cmd} node setup --client-id ${gcsv5::client_id} --secret ${gcsv5::client_secret} --ip-address ${gcsv5::ip_addr} --export-node ./node_info_new.json",
            cwd      => '/root/globus_conf',
            path     => '/bin:/usr/bin:/sbin:/usr/sbin',
            unless   => "if [[ `/usr/bin/ps -eaf|/usr/bin/grep gridftp|/usr/bin/grep -v grep |/usr/bin/wc -l` -gt 0 ]]; then exit 0; else exit 1;fi;",
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

    file { "$gcsv5::globus_conf/deployment-key.json":
        ensure => absent,
    }

    file { "$gcsv5::globus_conf/node_info.json":
        ensure => absent,
    }


}
