module MuckFriends
  module Mailers
    module FriendMailer

      extend ActiveSupport::Concern
  
      def follow(inviter, invited)
        @inviter = inviter
        @invited = invited
        mail(:to => invited.email, :subject => I18n.t('muck.friends.following_you', :name => inviter.login, :application_name => MuckEngine.configuration.application_name)) do |format|
          format.html
          format.text
        end
      end

      def friend_request(inviter, invited)
        @inviter = inviter
        @invited = invited
        mail(:to => invited.email, :subject => I18n.t('muck.friends.friend_request', :name => inviter.login, :application_name => MuckEngine.configuration.application_name)) do |format|
          format.html
          format.text
        end
      end
  
    end
  end
end