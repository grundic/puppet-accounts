# See README.md for details.
class accounts(
  $groups                  = {},
  $ssh_keys                = {},
  $users                   = {},
  $usergroups              = {},
  $accounts                = {},
  $start_uid               = undef,
  $start_gid               = undef,
  $ssh_authorized_key_title = '%{ssh_key}-on-%{account}',
  $dotfiles                 = {}
) {
  include ::accounts::config


  create_resources(group, $groups)

  create_resources(accounts::account, $accounts)

  # Remove users marked as absent
  $absent_users = keys(absents($users))
  user { $absent_users:
    ensure => absent,
  }
}
