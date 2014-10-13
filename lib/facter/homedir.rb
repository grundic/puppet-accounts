# Special fact with user's home directories.
# https://ask.puppetlabs.com/question/5373/how-to-reference-a-users-home-directory/
#

require 'etc'
Etc.passwd do |user|
  Facter.add("homedir_#{user.name}".intern) do
    setcode { user.dir }
  end
end
