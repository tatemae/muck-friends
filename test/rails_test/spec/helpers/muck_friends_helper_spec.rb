require File.dirname(__FILE__) + '/../spec_helper'

describe MuckFriendHelper do
  before do
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
  end
  describe "all_friends" do
    it "should render all friends of the given user" do
      helper.all_friends(@user).should include(@friend_guy.display_name)
    end
  end
  describe "mutual_friends" do
    helper.mutual_friends(@user, @mutual_friends_user).should include(@friend_guy.display_name)
  end
  describe "friends" do
    helper.friends(@user).should include(@friend_guy.display_name)
  end
  describe "followers" do
    helper.followers(@user).should include(@follower_guy.display_name)
  end
  describe "followings" do
    helper.followings(@user).should include(@guy_to_follow.display_name)
  end
  describe "friend_requests" do
    helper.followings(@user).should include(@follower_guy.display_name)
  end
  describe "block_user_link" do
    helper.block_user_link(@user, @follower_guy).should include(@follower_guy.display_name)
    helper.block_user_link(@user, @friend_guy).should include(@follower_guy.friend_guy)
  end
  describe "friend_link" do
    helper.friend_link(@user, @follower_guy).should include(@follower_guy.display_name)
  end
  describe "accept_follower_link" do
    helper.accept_follower_link(@user, @follower_guy).should include(@follower_guy.display_name)
  end
  describe "ignore_friend_request_link" do
    helper.ignore_friend_request_link(@user, @follower_guy).should include(@follower_guy.display_name)
  end
end