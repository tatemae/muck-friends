require 'muck_friends/config'
require 'muck_friends/models/friend'
require 'muck_friends/models/user'
require 'muck_friends/mailers/friend_mailer'
require 'muck_friends/engine'

module MuckFriends
  # Statuses Array
  BLOCKED = 2
  FRIENDING = 1
  FOLLOWING = 0
end