# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include gcsv5::repo
class gcsv5::repo (
  Hash   $yumrepo,
  Hash   $disable_dnfmod,
) {
  
  $yumrepo_defaults = {
    ensure  => present,
    enabled => true,
  }

  ensure_resources( 'yumrepo', $yumrepo, $yumrepo_defaults )

  $dnfmodule_disabled = {
    ensure   => disabled,
    provider => dnfmodule,
  }

  ensure_resources( 'package', $disable_dnfmod, $dnfmodule_disabled )
}
