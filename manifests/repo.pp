# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include gcsv5::repo
class gcsv5::repo (
  Hash   $yumrepo
) {
  
  $yumrepo_defaults = {
    ensure  => present,
    enabled => true,
  }

  ensure_resources( 'yumrepo', $yumrepo, $yumrepo_defaults )
}
