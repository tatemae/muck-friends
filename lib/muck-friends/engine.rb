require 'muck-friends'
require 'rails'

module MuckFriends
  class Engine < ::Rails::Engine
    
    def muck_name
      'muck-friends'
    end
    
    initializer 'muck-friends.helpers' do
      ActiveSupport.on_load(:action_view) do
        include MuckFriendsHelper
      end
    end
    
  end
end