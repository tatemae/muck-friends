class Friend < ActiveRecord::Base
  include MuckFriends::Models::MuckFriend
  include MuckActivities::Models::MuckActivityConsumer
end