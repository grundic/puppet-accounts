# Should not be used directly, see README.md for details.
# == Define: accounts::dotfile
# This define manages users' dot files. Because of puppet internals it' not
# easy to get $home folder of user, so we have choice of two optioins:
# 1) use custom fact - facts are evaluated before catalog compilation, so
# if out user is not defined yet, it will be empty. We can overcome it using
# `require_user=false` and running puppet two times.
# 2) set `home` for user resource and manage it
define accounts::dotfile(
  $dotfile_name        = regsubst($name, '^(\S+)-on-\S+$', '\1'),
  $account             = regsubst($name, '^\S+-on-(\S+)$', '\1'),
) {
  if has_key($::accounts::dotfiles, $dotfile_name) {
    $home_fact = "homedir_${account}"
    $home_fact_value = inline_template('<%= scope.lookupvar(@home_fact) %>')

    # check if user requirement is needed
    $req_value = $::accounts::dotfiles[$dotfile_name]['require_user']
    $require_user = $req_value ? {
      '' => true,
      default => $req_value
    }
    validate_bool($require_user)

    # first try to get home from custom fact
    if !empty($home_fact_value) {
      #notify {"Home path fact for user $account is $home_fact_value":}
      $userhome = $home_fact_value
    }
    # second, try to get value from defined resource type
    elsif $require_user == true {
      if !defined(User[$account]) {
        fail ("User ${account} is not managed by puppet, can't manage dotfile!")
      } else {
        $user_home = getparam(User[$account], 'home')
        $user_managehome = getparam(User[$account], 'managehome')
        if !empty($user_home) and $user_managehome {
          #notify {"Home path fact for managed user $account is $user_home":}
          $userhome = $user_home
        } else {
          fail ("User ${account} is managed, but one of `home` or `managehome` parameters is not defined!")
        }
      }
    }

    if !empty($userhome){
      # read values from hiera config
      $dotfile_path = $::accounts::dotfiles[$dotfile_name]['path'] # relative path
      $dotfile_content = $::accounts::dotfiles[$dotfile_name]['content']
      $dotfile_source = $::accounts::dotfiles[$dotfile_name]['source']
      $dotfile_mode = $::accounts::dotfiles[$dotfile_name]['mode']
      $dotfile_group = $::accounts::dotfiles[$dotfile_name]['group']

      $full_path = "${userhome}/${dotfile_path}"

      if empty($dotfile_group){

      # guess group by username match, if any
      $groups = getparam(User[$account], 'groups')
        if size($groups) > 0 {
          if member($groups, $account) {
            $owner_group = $account
          }
        }
      } else {
        $owner_group = $dotfile_group
      }

      # mimic `mkdir -p`
      $subdirs = suffix(
        prefix(subdirs($dotfile_path), "${userhome}/"),
        "-on-${dotfile_name}"
      )
      ::accounts::dotparents{$subdirs:
        account => $account,
        group   => $owner_group,
      }

      file {$name:
        path    => $full_path,
        content => $dotfile_content,
        source  => $dotfile_source,
        owner   => $account,
        group   => $owner_group,
        mode    => $dotfile_mode,
      }
    }
  }

  User<||> -> Accounts::Dotfile<||>
}
