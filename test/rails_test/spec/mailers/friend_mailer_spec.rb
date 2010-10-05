require File.dirname(__FILE__) + '/../spec_helper'

describe FriendMailer do

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end
  
  it "should send follow email" do
    inviter = Factory(:user)
    invited = Factory(:user)
    email = FriendMailer.follow(inviter, invited).deliver
    ActionMailer::Base.deliveries.should_not be_empty
    email.to.should == [invited.email]
    email.from.should == [MuckEngine.configuration.from_email]
  end
  
  it "should send friend_request email" do
    inviter = Factory(:user)
    invited = Factory(:user)
    response = FriendMailer.deliver_friend_request(inviter, invited)
    ActionMailer::Base.deliveries.should_not be_empty
    email = ActionMailer::Base.deliveries.last
    email.to.should == [invited.email]
    email.from.should == [MuckEngine.configuration.from_email]
  end
  
end  
