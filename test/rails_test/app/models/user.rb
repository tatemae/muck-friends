class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end
  include MuckUsers::Models::MuckUser
  include MuckFriends::Models::MuckUser
  include MuckProfiles::Models::User
  include MuckActivities::Models::MuckActivityConsumer
end