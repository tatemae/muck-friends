require File.dirname(__FILE__) + '/../spec_helper'

# Used to test muck_friend_user
class UserTest < ActiveSupport::TestCase

  describe "user instance with include MuckFriends::Models::User" do
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
        assert @quentin.follow(@aaron)
        assert @aaron.become_friends_with(@quentin)
        assert @quentin.drop_friend(@aaron)
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
          assert @quentin.follow(@aaron)
          assert @aaron.become_friends_with(@quentin)
          assert @quentin.drop_friend(@aaron)
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
        assert @quentin.follow(@aaron)
        assert @aaron.become_friends_with(@quentin)
        assert @quentin.drop_friend(@aaron)
        @quentin.reload
        @aaron.reload
        @quentin.should_not be_friend_of(@aaron)
        @quentin.should_not be_following(@aaron)
        @quentin.followed_.should be_y(@aaron)
        @aaron.should_not be_friend_of(@quentin)
        @aaron.followi.should be_g(@quentin)
        @aaron.should_not be_followed_by(@quentin)
      end
      
      describe "drop_friend" do
        before do
          assert @quentin.follow(@aaron)
        end
        it "should stop following the other user but retain follow for other user " do
          assert @aaron.become_friends_with(@quentin)
          assert @quentin.drop_friend(@aaron)
          !@quentin.followings.any?{|f| f.id.should == @aaron.id}
          @aaron.followings.any?{|f| f.id.should == @quentin.id}
        end
        it "should stop being friends with the user but retain follow for other user" do
          assert !@quentin.drop_friend(@aaron) # @aaron wasn't following @quentin so drop_friend will return false indicating that a friend object wasn't found to let @aaron continue following @quentin
          !@quentin.followings.any?{|f| f.id.should == @aaron.id}
        end
      end

      it "should have friends" do
        assert @aaron.follow(@quentin)
        assert @quentin.become_friends_with(@aaron)
        assert @friend_guy.follow(@quentin)
        assert @quentin.become_friends_with(@friend_guy)
        @quentin.reload
        @aaron.reload
        @friend_guy.reload
        @quentin.friends.any?{|f| f.id == @aaron.id || f.id.should == @friend_guy.id}
        @aaron.friends.any?{|f| f.id.should == @quentin.id}
        @friend_guy.friends.any?{|f| f.id.should == @quentin.id}
      end

      it "should not have follower as friend" do
        assert @follower_guy.follow(@quentin)
        !@quentin.friends.any?{|f| f.id.should == @follower_guy.id}
      end

      it "should have followers" do
        assert @follower_guy.follow(@quentin)
        @quentin.followers.any?{|f| f.id.should == @follower_guy.id}
      end

      it "should have people user follows (followings)" do
        assert @follower_guy.follow(@quentin)
        @follower_guy.followings.any?{|f| f.id.should == @quentin.id}
      end

      it "should be a friend" do
        assert @quentin.follow(@aaron)
        assert @quentin.follow(@friend_guy)
        assert @aaron.become_friends_with(@quentin)
        assert @friend_guy.become_friends_with(@quentin)
        2.should == @quentin.occurances_as_friend.count
      end

      it "should find friendships initiated by me" do
        assert @quentin.follow(@aaron)
        assert @quentin.follow(@friend_guy)
        @quentin.friendships_initiated_by_me.count.should == 2
        @quentin.friendships_initiated_by_me.any?{|f| f.id == @aaron.id || f.id.should == @friend_guy.id}
      end

      it "should find friendships not initiated by me" do
        assert @aaron.follow(@quentin)
        assert @friend_guy.follow(@quentin)
        @quentin.friendships_not_initiated_by_me.count.should == 2
        @quentin.friendships_not_initiated_by_me.any?{|f| f.id == @aaron.id || f.id.should == @friend_guy.id}
      end

      it "shouldfollow the user" do
        assert @quentin.follow(@aaron)
        @quentin.followings.any?{|f| f.id.should == @aaron.id}
      end

      it "should stop following the user" do
        assert @quentin.follow(@aaron)
        assert @quentin.stop_following(@aaron)
        !@quentin.followings.any?{|f| f.id.should == @aaron.id}
      end

      it "should become friends" do
        assert @quentin.follow(@aaron)
        assert @aaron.become_friends_with(@quentin)
        @quentin.reload
        @aaron.reload
        @aaron.friends.any?{|f| f.id.should == @quentin.id}
        @quentin.friends.any?{|f| f.id.should == @aaron.id}
      end

      it "should not have a network" do
        assert !@quentin.has_network?
      end

      it "should have a network" do
        assert @quentin.follow(@aaron)
        assert @quentin.has_network?
      end

      it "should block user" do
        assert @quentin.follow(@aaron)
        assert @aaron.block_user(@quentin)
        !@aaron.friends.any?{|f| f.id.should == @quentin.id}
        !@aaron.followers.any?{|f| f.id.should == @quentin.id}
        !@quentin.followings.any?{|f| f.id.should == @aaron.id}
        @aaron.block.should be_d(@quentin)
      end

      it "should unblock user" do
        assert @quentin.follow(@aaron)
        assert @aaron.block_user(@quentin)
        assert @aaron.unblock_user(@quentin)
        @aaron.followers.any?{|f| f.id.should == @quentin.id}
        @quentin.followings.any?{|f| f.id.should == @aaron.id}
        @aaron.block.should_not be_d(@quentin)
      end
      
      it "should have friend relation" do
        assert @quentin.follow(@aaron)
        assert @aaron.friendship_with(@quentin)
      end
      
      it "should not have friend relation" do
        assert !@quentin.friendship_with(@aaron)
      end
      
    end
    
  end

end