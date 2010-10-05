class Friend < ActiveRecord::Base
  include MuckFriends::Models::Friend
  include MuckActivities::Models::ActivityConsumer
end