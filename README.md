Accounts
========

[![Build Status](https://travis-ci.org/camptocamp/puppet-accounts.png?branch=master)](https://travis-ci.org/camptocamp/puppet-accounts)

Usage
-----

```puppet
class { 'accounts':
  groups                   => hiera_hash('accounts::groups', {}),
  ssh_keys                 => hiera_hash('accounts::ssh_keys', {}),
  users                    => hiera_hash('accounts::users', {}),
  usergroups               => hiera_hash('accounts::usergroups', {}),
  accounts                 => hiera_hash('accounts::accounts', {}),
  ssh_authorized_key_title => '%{ssh_keys[\'%{ssh_key}\'][\'comment\'] on %{user}',
  dotfiles                 => hiera_hash('accounts::dotfiles', {}),
}
```

### common.yaml
```
---
accounts::dotfiles:
  simple:
    path: .simple
    source: /etc/lsb-release
  complex:
    path: dir1/dir2/file.txt
    content: "This is sample dotfile content\n"
  complex2:
    path: dir1/dir2/file2.txt
    content: "File in the same folder\n"
    mode: "660"
  do_not_require_home:
    path: some-file.txt
    content: "This file will be created on second puppet run, after user home fact will be available\n" 
    group: users
    require_user: false

accounts::ssh_keys:
  foo:
    comment: foo@example.com
    type: ssh-rsa
    public: FOO-S-RSA-PUBLIC-KEY
  bar:
    comment: bar@example.com
    type: ssh-rsa
    public: BAR-S-RSA-PUBLIC-KEY

accounts::users:
  foo:
    uid: 1000
    comment: Foo
  bar:
    uid: 1001
    comment: Bar
  baz:
    # Remove user baz from every node (unless overridden)
    ensure: absent
  qux:
    uid: 1003
    comment: Qux

accounts::usergroups:
  foo:
    - foo
    - bar
  bar:
    - baz
    - qux

# Create foo and bar accounts on every node
accounts::accounts:
  foo:
    groups:
      - foo
    authorized_keys:
      - foo
      - bar
      - baz
    dotfiles:
      - simple
      - complex
      - complex2
  bar:
    groups:
      - foo
      - bar
      - baz
    authorized_keys:
      - bar
    dotfiles:
      - complex2
      - "do_not_require_home"
  @foo:
    groups:
      - qux
```

### foo.example.com.yaml
```
---
accounts::groups:
  foo:
    gid: 1000
  bar:
    system: true

accounts::ssh_keys:
  baz:
    type: ssh-rsa
    private: BAZ-S-PRIVATE-KEY
    public: BAZ-S-RSA-PUBLIC-KEY

accounts::users:
  baz:
    uid: 1002

# Create baz accounts on foo.example.com.yaml only
accounts::accounts:
  baz:
    groups:
      - foo
    authorized_keys:
      - @foo
```

### bar.example.com.yaml
```
---
accounts::ssh_keys:
  quux:
    type: ssh-rsa
    public: QUUX-S-RSA-PUBLIC-KEY

accounts::users:
  quux:
    uid: 1003

# Create quux accounts on bar.example.com.yaml only
accounts::accounts:
  quux:
    groups:
      - quux
    authorized_keys:
      quux: {}
      foo:
        options: ['no-pty', 'no-port-forwarding', 'no-X11-forwarding']
        target: /etc/sshd/authorized_keys/foo
```
