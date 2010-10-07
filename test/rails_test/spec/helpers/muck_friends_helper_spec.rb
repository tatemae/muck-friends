require File.dirname(__FILE__) + '/../spec_helper'

describe MuckFriendsHelper do
  before(:each) do
    @user = Factory(:user)
    @mutual_friends_user = Factory(:user)
    @guy_to_follow = Factory(:user)
    @friend_guy = Factory(:user)
    @follower_guy = Factory(:user)
    @follower_guy.follow(@user)
    @friend_guy.follow(@user)
    @friend_guy.follow(@mutual_friends_user)
    @user.follow(@guy_to_follow)
    @user.become_friends_with(@friend_guy)
    @mutual_friends_user.become_friends_with(@friend_guy)
    @user.reload
    @friend_guy.reload
    @mutual_friends_user.reload
  end
  describe "all_friends" do
    it "should render all friends of the given user" do
      helper.all_friends(@user).should include(@friend_guy.display_name)
    end
  end
  describe "mutual_friends" do
    it "should render mutual of the given users" do
      helper.mutual_friends(@user, @mutual_friends_user).should include(@friend_guy.display_name)
    end
  end
  describe "friends" do
    it "should render friends of the given user" do
      helper.friends(@user).should include(@friend_guy.display_name)
    end
  end
  describe "followers" do
    it "should render followers of the given user" do
      helper.followers(@user).should include(@follower_guy.display_name)
    end
  end
  describe "followings" do
    it "should render followings for the given user" do
      helper.followings(@user).should include(@guy_to_follow.display_name)
    end
  end
  describe "friend_requests" do
    it "should render friend_requests for the given user" do
      helper.followings(@user).should include(@guy_to_follow.display_name)
    end
  end
  describe "block_user_link" do
    it "should render block user links" do
      helper.block_user_link(@user, @follower_guy).should include(@follower_guy.display_name)
      helper.block_user_link(@user, @friend_guy).should include(@friend_guy.display_name)
    end
  end
  describe "friend_link" do
    it "should render friend link" do
      helper.friend_link(@user, @follower_guy).should include(@follower_guy.display_name)
    end
  end
  describe "accept_follower_link" do
    it "should render accept follower link" do
      helper.accept_follower_link(@user, @follower_guy).should include(user_friends_path(@user, @follower_guy))
    end
  end
  describe "ignore_friend_request_link" do
    it "should render ignore friend request" do
      helper.ignore_friend_request_link(@user, @follower_guy).should include(user_friend_path(@user, @follower_guy))
    end
  end
end