require 'muck-friends/config'
require 'muck-friends/models/friend'
require 'muck-friends/models/user'
require 'muck-friends/mailers/friend_mailer'
require 'muck-friends/engine'

module MuckFriends
  # Statuses Array
  BLOCKED = 2
  FRIENDING = 1
  FOLLOWING = 0
end