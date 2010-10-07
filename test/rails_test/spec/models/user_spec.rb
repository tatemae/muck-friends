require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe "user instance with 'include MuckFriends::Models::MuckUser'" do
    it { should have_many :friendships }
    it { should have_many :follower_friends }
    it { should have_many :following_friends }
    it { should have_many :blocked_friends }

    it { should have_many :friends }
    it { should have_many :followers }
    it { should have_many :followings }
    it { should have_many :blocked_users }

    it { should have_many :initiated_by_me }
    it { should have_many :not_initiated_by_me }
    
    it { should have_many :friendships_initiated_by_me }
    it { should have_many :friendships_not_initiated_by_me }
    
    it { should have_many :occurances_as_friend }
  end

  describe "user as friend" do
    before do
      Friend.destroy_all
      @aaron = Factory(:user)
      @quentin = Factory(:user)
      @friend_guy = Factory(:user)
      @follower_guy = Factory(:user)
    end

    describe "following disabled" do
      before do
        @temp_enable_following = MuckFriends.configuration.enable_following
        MuckFriends.configuration.enable_following = false
      end
      after do
        MuckFriends.configuration.enable_following = @temp_enable_following
      end
      it "should stop being friends" do
        @quentin.follow(@aaron).should be_true
        @aaron.become_friends_with(@quentin).should be_true
        @quentin.drop_friend(@aaron).should be_true
        @quentin.reload
        @aaron.reload
        @quentin.should_not be_friend_of(@aaron)
        @quentin.should_not be_following(@aaron)
        @quentin.should_not be_followed_by(@aaron)
        @aaron.should_not be_friend_of(@quentin)
        @aaron.should_not be_following(@quentin)
        @aaron.should_not be_followed_by(@quentin)
      end
      describe "drop_friend following not enabled" do
        before do
          @quentin.follow(@aaron).should be_true
          @aaron.become_friends_with(@quentin).should be_true
          @quentin.drop_friend(@aaron).should be_true
        end
        it "should stop being friends with the user and don't retain follow" do
          !@quentin.followings.any?{|f| f.id.should == @aaron.id}
          !@aaron.followings.any?{|f| f.id.should == @quentin.id}
        end
      end
    end

    describe "following enabled" do
      before do
        @temp_enable_following = MuckFriends.configuration.enable_following
        MuckFriends.configuration.enable_following = true
      end
      after do
        MuckFriends.configuration.enable_following = @temp_enable_following
      end
      it "should stop being friends but still allow follow" do
        @quentin.follow(@aaron).should be_true
        @aaron.become_friends_with(@quentin).should be_true
        @quentin.drop_friend(@aaron).should be_true
        @quentin.reload
        @aaron.reload
        @quentin.should_not be_friend_of(@aaron)
        @quentin.should_not be_following(@aaron)
        @quentin.followed_by?(@aaron).should be_true
        @aaron.should_not be_friend_of(@quentin)
        @aaron.following?(@quentin).should be_true
        @aaron.should_not be_followed_by(@quentin)
      end
      
      describe "drop_friend" do
        before do
          @quentin.follow(@aaron).should be_true
        end
        it "should stop following the other user but retain follow for other user " do
          @aaron.become_friends_with(@quentin).should be_true
          @quentin.drop_friend(@aaron).should be_true
          @quentin.followings.any?{|f| f.id == @aaron.id}.should be_false
          @aaron.followings.any?{|f| f.id == @quentin.id}.should be_true
        end
        it "should stop being friends with the user but retain follow for other user" do
          @quentin.drop_friend(@aaron).should be_false # @aaron wasn't following @quentin so drop_friend will return false indicating that a friend object wasn't found to let @aaron continue following @quentin
          @quentin.followings.any?{|f| f.id == @aaron.id}.should be_false
        end
      end

      it "should have friends" do
        @aaron.follow(@quentin).should be_true
        @quentin.become_friends_with(@aaron).should be_true
        @friend_guy.follow(@quentin).should be_true
        @quentin.become_friends_with(@friend_guy).should be_true
        @quentin.reload
        @aaron.reload
        @friend_guy.reload
        @quentin.friends.any?{|f| f.id == @aaron.id || f.id == @friend_guy.id}.should be_true
        @aaron.friends.any?{|f| f.id == @quentin.id}.should be_true
        @friend_guy.friends.any?{|f| f.id == @quentin.id}.should be_true
      end

      it "should not have follower as friend" do
        @follower_guy.follow(@quentin).should be_true
        @quentin.friends.any?{|f| f.id == @follower_guy.id}.should be_false
      end

      it "should have followers" do
        @follower_guy.follow(@quentin).should be_true
        @quentin.followers.any?{|f| f.id == @follower_guy.id}.should be_true
      end

      it "should have people user follows (followings)" do
        @follower_guy.follow(@quentin).should be_true
        @follower_guy.followings.any?{|f| f.id.should == @quentin.id}
      end

      it "should be a friend" do
        @quentin.follow(@aaron).should be_true
        @quentin.follow(@friend_guy).should be_true
        @aaron.become_friends_with(@quentin).should be_true
        @friend_guy.become_friends_with(@quentin).should be_true
        @quentin.occurances_as_friend.count.should == 2
      end

      it "should find friendships initiated by me" do
        @quentin.follow(@aaron).should be_true
        @quentin.follow(@friend_guy).should be_true
        @quentin.friendships_initiated_by_me.count.should == 2
        @quentin.friendships_initiated_by_me.any?{|f| f.id == @aaron.id || f.id == @friend_guy.id}.should be_true
      end

      it "should find friendships not initiated by me" do
        @aaron.follow(@quentin).should be_true
        @friend_guy.follow(@quentin).should be_true
        @quentin.friendships_not_initiated_by_me.count.should == 2
        @quentin.friendships_not_initiated_by_me.any?{|f| f.id == @aaron.id || f.id == @friend_guy.id}.should be_true
      end

      it "should follow the user" do
        @quentin.follow(@aaron).should be_true
        @quentin.followings.any?{|f| f.id == @aaron.id}.should be_true
      end

      it "should stop following the user" do
        @quentin.follow(@aaron).should be_true
        @quentin.stop_following(@aaron).should be_true
        @quentin.followings.any?{|f| f.id == @aaron.id}.should be_false
      end

      it "should become friends" do
        @quentin.follow(@aaron).should be_true
        @aaron.become_friends_with(@quentin).should be_true
        @quentin.reload
        @aaron.reload
        @aaron.friends.any?{|f| f.id == @quentin.id}.should be_true
        @quentin.friends.any?{|f| f.id == @aaron.id}.should be_true
      end

      it "should not have a network" do
        @quentin.has_network?.should be_false
      end

      it "should have a network" do
        @quentin.follow(@aaron).should be_true
        @quentin.has_network?.should be_true
      end

      it "should block user" do
        @quentin.follow(@aaron).should be_true
        @aaron.block_user(@quentin).should be_true
        @aaron.friends.any?{|f| f.id == @quentin.id}.should be_false
        @aaron.followers.any?{|f| f.id == @quentin.id}.should be_false
        @quentin.followings.any?{|f| f.id == @aaron.id}.should be_false
        @aaron.blocked?(@quentin).should be_true
      end

      it "should unblock user" do
        @quentin.follow(@aaron).should be_true
        @aaron.block_user(@quentin).should be_true
        @aaron.unblock_user(@quentin).should be_true
        @aaron.followers.any?{|f| f.id == @quentin.id}.should be_true
        @quentin.followings.any?{|f| f.id == @aaron.id}.should be_true
        @aaron.blocked?(@quentin).should be_false
      end
      
      it "should have friend relation" do
        @quentin.follow(@aaron).should be_true
        @aaron.friendship_with(@quentin).should be_true
      end
      
      it "should not have friend relation" do
        @quentin.friendship_with(@aaron).should be_false
      end
      
    end
    
  end

end