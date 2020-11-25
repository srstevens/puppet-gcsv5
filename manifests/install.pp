# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include gcsv5::install
class gcsv5::install {
    package { $gcsv5::package_name:
        ensure => 'present',
    }
}
