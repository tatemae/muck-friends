require File.dirname(__FILE__) + '/../spec_helper'

describe Friend do

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
        @friend_guy.following?(@aaron).should be_false
        lambda{
          Friend.add_follower(@friend_guy, @aaron)
          @aaron.reload
          @friend_guy.reload
          @friend_guy.following?(@aaron).should be_true
        }.should change(Friend, :count).by(1)
        lambda{
          Friend.stop_following(@friend_guy, @aaron)
          @aaron.reload and @friend_guy.reload
          @friend_guy.following?(@aaron).should be_false          
        }.should change(Friend, :count).by(-1)
      end
      
      it "should not have any effects on followers" do
        lambda{
          Friend.stop_following(@friend_guy, @aaron).should be_false
        }.should_not change(Friend, :count)
      end
      
      it "should not have any effect on friends" do
        lambda{
          Friend.stop_being_friends(@friend_guy, @aaron).should be_true # will return true as long as no friend entries are found for the given users
        }.should_not change(Friend, :count)
      end
    
      it "should not create an association with the same user" do
        Friend.add_follower(@quentin, @quentin).should be_false
        Friend.count.should == 0
      end

      it "should create a new follower" do
        Friend.add_follower(@quentin, @aaron).should be_true
        Friend.count.should == 1
        @quentin.reload.friend_of?(@aaron.reload).should be_false
        @quentin.following?(@aaron).should be_true
        @aaron.followed_by?(@quentin).should be_true
      end

      it "should not find a following to turn into a friendship so just makes a follower" do
        Friend.make_friends(@quentin, @aaron).should be_true
        Friend.count.should == 1   
        @quentin.reload.friend_of?(@aaron.reload).should be_false
        @quentin.following?(@aaron).should be_true
        @aaron.followed_by?(@quentin).should be_true
      end

      it "should turn a following into a friendship" do
        assert Friend.add_follower(@quentin, @aaron)
        Friend.count.should == 1
        assert Friend.make_friends(@aaron, @quentin)
        Friend.count.should == 2
        @quentin.reload
        @aaron.reload
        @quentin.friend_of?(@aaron).should be_true
        @aaron.friend_of?(@quentin).should be_true
      end

      it "should turn a following into a friendship with reversed users" do
        assert Friend.add_follower(@quentin, @aaron)
        Friend.count.should == 1
        assert Friend.make_friends(@quentin, @aaron)
        Friend.count.should == 2
        @quentin.reload
        @aaron.reload
        @quentin.friend_of?(@aaron).should be_true
        @aaron.friend_of?(@quentin).should be_true
      end

      it "should not find a friendship so can't stop being friends" do
        Friend.revert_to_follower(@quentin, @aaron).should be_false # revert_to_follower will return true as long as the desired state (reverted to follower) is achieved.
      end

      it "should revert to follower" do
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
        @quentin.followed_by?(@aaron).should be_true
        @aaron.should_not be_friend_of(@quentin)
        @quentin.followed_by?(@aaron).should be_true
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
      
      it "should show if user is blocked" do
        assert Friend.add_follower(@quentin, @aaron)
        Friend.block_user(@aaron, @quentin)
        Friend.blocked?(@aaron, @quentin).should be_true
      end
      
    end
    
    it "should ignore block user request" do
      Friend.block_user(nil, nil).should be_false
    end
    
    describe "activities" do
      before do
        @temp_enable_friend_activity = MuckFriends.configuration.enable_friend_activity
        MuckFriends.configuration.enable_friend_activity = true
      end
      after do
        MuckFriends.configuration.enable_friend_activity = @temp_enable_friend_activity
      end
      it "should add follow activity" do
        lambda{
          Friend.add_follower(@quentin, @aaron)          
        }.should change(Activity, :count).by(1)
      end
      it "should add friends with activity" do
        lambda{
          Friend.make_friends(@quentin, @aaron)          
        }.should change(Activity, :count).by(1)
      end
    end
  end
  
end