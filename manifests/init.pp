# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include gcsv5
class gcsv5 (

    # Repo and pkgs
    String $release_url = 'https://downloads.globus.org/toolkit/globus-connect-server/globus-connect-server-repo-latest.noarch.rpm',
    String $repo_baseurl = "https://downloads.globus.org/toolkit/gt6/stable/rpm/el/${facts['os']['release']['major']}/\$basearch/",
    String $repo_testing_baseurl = "https://downloads.globus.org/toolkit/gt6/testing/rpm/el/${facts['os']['release']['major']}/\$basearch/",
    String $repo_baseurl_v5 = "https://downloads.globus.org/globus-connect-server/stable/rpm/el/${facts['os']['release']['major']}/\$basearch/",
    String $repo_testing_baseurl_v5 = "https://downloads.globus.org/globus-connect-server/testing/rpm/el/${facts['os']['release']['major']}/\$basearch/",
    String $package_name = 'globus-connect-server54',
    Array $repo_dependencies = ['yum-plugin-priorities'],

    # Globus Config 
    String $client_id = '',
    String $client_secret = '',
    String $deployment_key = '',
    String $node_info = '',
    String $gcs_cmd = 'globus-connect-server',
    String $ip_addr = '',


) {

    contain gcsv5::repo
    contain gcsv5::install
    contain gcsv5::config

    Class['gcsv5::repo']
    -> Class['gcsv5::install']
    -> Class['gcsv5::config']
}
