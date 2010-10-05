require File.dirname(__FILE__) + '/../spec_helper'

# Used to test muck_friend
class FriendTest < ActiveSupport::TestCase

  describe "A Friend instance" do    
    it { should belong_to :inviter }
    it { should belong_to :invited }
  end
  
  describe "friending" do
    before do
      @aaron = Factory(:user)
      @quentin = Factory(:user)
      @friend_guy = Factory(:user)
      @follower_guy = Factory(:user)
    end

    describe "No entries in friends" do
      before do
        Friend.destroy_all
      end
      it "should be able to start and stop following aaron" do
        @friend_guy.followi.should_not be_g(@aaron)
        assert_difference "Friend.count" do
          Friend.add_follower(@friend_guy, @aaron)
          @aaron.reload
          @friend_guy.reload
          @friend_guy.followi.should be_g(@aaron)
        end
        assert_difference "Friend.count", -1 do
          Friend.stop_following(@friend_guy, @aaron)
          @aaron.reload and @friend_guy.reload
          @friend_guy.followi.should_not be_g(@aaron)
        end
      end

      it "should not have any effect on friends" do
        assert_no_difference "Friend.count" do        
          assert !Friend.stop_following(@friend_guy, @aaron)
        end
        assert_no_difference "Friend.count" do        
          assert Friend.stop_being_friends(@friend_guy, @aaron) # will return true as long as no friend entries are found for the given users
        end
      end
    
      it "should not create an association with the same user" do
        assert !Friend.add_follower(@quentin, @quentin)
        Friend.count.should == 0
      end

      it "shouldcreate a new follower" do
        assert Friend.add_follower(@quentin, @aaron)
        Friend.count.should == 1
        @quentin.reload.friend_.should_not be_f(@aaron.reload)
        @quentin.followi.should be_g(@aaron)
        @aaron.followed_.should be_y(@quentin)
      end

      it "should not find a following to turn into a friendship so just makes a follower" do
        assert Friend.make_friends(@quentin, @aaron)
        Friend.count.should == 1
        @quentin.reload.friend_.should_not be_f(@aaron.reload)
        @quentin.followi.should be_g(@aaron)
        @aaron.followed_.should be_y(@quentin)
      end

      it "shouldturn a following into a friendship" do
        assert Friend.add_follower(@quentin, @aaron)
        Friend.count.should == 1
        assert Friend.make_friends(@aaron, @quentin)
        Friend.count.should == 2
        @quentin.reload
        @aaron.reload
        @quentin.friend_.should be_f(@aaron)
        @aaron.friend_.should be_f(@quentin)
      end

      it "shouldturn a following into a friendship with reversed users" do
        assert Friend.add_follower(@quentin, @aaron)
        Friend.count.should == 1
        assert Friend.make_friends(@quentin, @aaron)
        Friend.count.should == 2
        @quentin.reload
        @aaron.reload
        @quentin.friend_.should be_f(@aaron)
        @aaron.friend_.should be_f(@quentin)
      end

      it "should not find a friendship so can't stop being friends" do
        assert !Friend.revert_to_follower(@quentin, @aaron) # revert_to_follower will return true as long as the desired state (reverted to follower) is achieved.
      end

      it "shouldrevert to follower" do
        assert Friend.add_follower(@quentin, @aaron)
        assert Friend.make_friends(@quentin, @aaron)
        Friend.count.should == 2
        @quentin.reload
        @aaron.reload
        assert Friend.revert_to_follower(@quentin, @aaron)
        Friend.count.should == 1
        @quentin.reload
        @aaron.reload
        @quentin.should_not be_friend_of(@aaron)
        @quentin.should_not be_following(@aaron)
        @quentin.followed_.should be_y(@aaron)
        @aaron.should_not be_friend_of(@quentin)
        @aaron.followi.should be_g(@quentin)
        @aaron.should_not be_followed_by(@quentin)
      end

      it "should stop being friends" do
        assert Friend.add_follower(@quentin, @aaron)
        assert Friend.make_friends(@quentin, @aaron)
        Friend.count.should == 2
        @quentin.reload
        @aaron.reload
        assert Friend.stop_being_friends(@quentin, @aaron)
        @quentin.reload
        @aaron.reload
        @quentin.should_not be_friend_of(@aaron)
        @quentin.should_not be_following(@aaron)
        @quentin.should_not be_followed_by(@aaron)
        @aaron.should_not be_friend_of(@quentin)
        @aaron.should_not be_following(@quentin)
        @aaron.should_not be_followed_by(@quentin)
      end

      it "should block friend" do
        assert Friend.add_follower(@quentin, @aaron)
        assert Friend.make_friends(@quentin, @aaron)
        Friend.block_user(@quentin, @aaron)
        @quentin.blocked_users.should include(@aaron)
        @quentin.should_not be_friend_of(@aaron)
        @quentin.should_not be_followed_by(@aaron)
        @quentin.should_not be_following(@aaron)
        @aaron.should_not be_friend_of(@quentin)
        @aaron.should_not be_followed_by(@quentin)
        @aaron.should_not be_following(@quentin)
      end
    
      it "should block follower" do
        assert Friend.add_follower(@quentin, @aaron)
        Friend.block_user(@aaron, @quentin)
        @aaron.blocked_users.should include(@quentin)
        @quentin.should_not be_friend_of(@aaron)
        @quentin.should_not be_following(@aaron)
        @aaron.should_not be_friend_of(@quentin)
        @aaron.should_not be_following(@quentin)
        @aaron.should_not be_followed_by(@quentin)
      end
      
      it "shouldshow if user is blocked" do
        assert Friend.add_follower(@quentin, @aaron)
        Friend.block_user(@aaron, @quentin)
        Friend.block.should be_d(@aaron, @quentin)
      end
      
    end
    
    it "shouldignore block user request" do
      assert !Friend.block_user(nil, nil)
    end
    
    describe "activities" do
      before do
        @temp_enable_friend_activity = MuckFriends.configuration.enable_friend_activity
        MuckFriends.configuration.enable_friend_activity = true
      end
      after do
        MuckFriends.configuration.enable_friend_activity = @temp_enable_friend_activity
      end
      it "shouldadd follow activity" do
        assert_difference "Activity.count", 1 do
          Friend.add_follower(@quentin, @aaron)
        end
      end
      it "shouldadd friends with activity" do
        assert_difference "Activity.count", 1 do
          Friend.make_friends(@quentin, @aaron)
        end
      end
    end
  end
  
end