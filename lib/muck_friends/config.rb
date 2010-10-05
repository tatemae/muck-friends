module MuckFriends
  
  def self.configuration
    # In case the user doesn't setup a configure block we can always return default settings:
    @configuration ||= Configuration.new
  end
  
  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :allow_following
    attr_accessor :enable_friending
    attr_accessor :enable_friend_activity
    
    def initialize
      # Friend Configuration
      # The friend system provides a hybrid friend/follow model.  Either mode can be turned off or both can be enabled
      # If only following is enabled then users will be provided the ability to follow, unfollow, and block
      # If only friending is enabled then users will be provided a 'friend request' link and the ability to accept friend requests
      # If both modes are are enabled then users will be able to follow other users.  A mutual follow results in 'friends'.  An unfollow 
      # leaves the other party as just a follower.
      # Note that at least one mode must be enabled.
      enable_following = true         # Turn on 'following'.  This is similar to the 'follow' functionality on Twitter in that it let's users watch one 
                                      # another's activities without having explicit permission from the user.  A mutual follow essentially becomes a
                                      # friendship.
                                      # If enable_following is true and enable_friending is false then only follow/unfollow links will be shown
                                      # If enable_following is false and enable_friending is true then only friend request and unfriend links will be shown
                                      # If enable_following is true and enable_friending is true then a hybrid model will be used.  Users can follow
                                      # each other without permission but a mutual follow will result in a friendship.  Defriending a user will result in the
                                      # other user becoming a follower
      enable_friending = true         # Turn on friend system.
      enable_friend_activity = true   # If true then friend related activity will show up in the activity feed.  Requires muck-activities gem
    end
    
  end
end