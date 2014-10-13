# Define for creating parent of some file
define accounts::dotparents(
  $path    = regsubst($name, '^(\S+)-on-\S+$', '\1'),
  $account = undef,
  $group   = undef,
){
  if !defined(File[$path]){
    file {$path:
      ensure => 'directory',
      owner  => $account,
      group  => $group,
    }
  }
}
