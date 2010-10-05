class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
  end
  include MuckUsers::Models::User
  include MuckFriends::Models::User
  include MuckProfiles::Models::User
  include MuckActivities::Models::ActivityConsumer
end