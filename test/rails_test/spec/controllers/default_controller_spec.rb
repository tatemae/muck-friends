require File.dirname(__FILE__) + '/../spec_helper'

# this tests the friends helper methods
class Muck::DefaultControllerTest < ActionController::TestCase

  tests DefaultController

  describe "" do
    before do
      @aaron = Factory(:user)
      @quentin = Factory(:user)
      @follower1 = Factory(:user)
      @follower2 = Factory(:user)
      @friend1 = Factory(:user)
      @friend2 = Factory(:user)
      @friend3 = Factory(:user)
      @mutual_friend1 = Factory(:user)
      @mutual_friend2 = Factory(:user)
      
      # aaron's followers
      @follower1.follow(@aaron)
      @follower2.follow(@aaron)
      
      # aaron's friends
      @friend1.follow(@aaron)
      @friend2.follow(@aaron)
      @friend2.follow(@aaron)
      @aaron.become_friends_with(@friend1)
      @aaron.become_friends_with(@friend2)
      @aaron.become_friends_with(@friend3)
                  
      # mutual friends
      @mutual_friend1.follow(@aaron)
      @mutual_friend2.follow(@aaron)
      @aaron.become_friends_with(@mutual_friend1)
      @aaron.become_friends_with(@mutual_friend2)

      @mutual_friend1.follow(@quentin)
      @mutual_friend2.follow(@quentin)
      @quentin.become_friends_with(@mutual_friend1)
      @quentin.become_friends_with(@mutual_friend2)
      
      @controller.stub!(:current_user).and_return(@aaron)
      @controller.stub!(:other_user).and_return(@quentin)
    end
    
    describe "block user link" do
      describe "users have no relationship" do
        before do
          @controller.stub!(:current_user).and_return(@aaron)
          get :block_user_link
        end
        it { should respond_with :success }
        it { should render_template :block_user_link }
        it "should not have block link in the body" do
          @response.body.should_not include(I18n.t('muck.friends.block', :user => @quentin.display_name)
          @response.body.should_not include(I18n.t('muck.friends.unblock', :user => @quentin.display_name)
        end
      end      
      describe "logged in as aaron" do
        describe "quentin following aaron" do
          before do
            @quentin.should follow(@aaron)
            @controller.stub!(:current_user).and_return(@aaron)
            get :block_user_link
          end
          it { should respond_with :success }
          it { should render_template :block_user_link }
          it "should have 'block' in the body" do
            @response.body.should include(I18n.t('muck.friends.block', :user => @quentin.display_name)
          end
        end
        describe "aaron has blocked quentin" do
          before do
            @quentin.should follow(@aaron)
            @aaron.should block_user(@quentin)
            @aaron.should blocked?(@quentin)
            @controller.stub!(:current_user).and_return(@aaron)
            get :block_user_link
          end
          it { should respond_with :success }
          it { should render_template :block_user_link }
          it "should have 'unblock' in the body" do
            @response.body.should include(I18n.t('muck.friends.unblock', :user => @quentin.display_name)
          end
        end
      end
    end
    
    describe "friend link" do
      before do
        @enable_following = MuckFriends.configuration.enable_following
        @enable_friending = MuckFriends.configuration.enable_friending
      end
      after do
        # Reset global config
        MuckFriends.configuration.enable_following = @enable_following
        MuckFriends.configuration.enable_friending = @enable_friending
      end
      
      describe "enable_following is true and enable_friending is true" do
        before do
          MuckFriends.configuration.enable_following = true
          MuckFriends.configuration.enable_friending = true
        end
        describe "no current user" do
          before do
            @controller.stub!(:current_user).and_return(nil)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have login/signup in the body" do
            @response.body.should include(I18n.t('muck.friends.login')
          end
        end
        describe "current user is not friends with other user" do
          before do
            @other_user = Factory(:user)
            @controller.stub!(:other_user).and_return(@other_user)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have 'follow' in the body" do
            @response.body.should include(I18n.t('muck.friends.start_following', :user => @other_user.display_name)
          end
        end
        describe "current user is friends with other user" do
          before do
            @controller.stub!(:other_user).and_return(@friend1)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have 'stop being friends' in the body" do
            @response.body.should include(I18n.t('muck.friends.stop_being_friends_with', :user => @friend1.display_name)
          end
        end
        describe "current user is not friend with other user, but other user follows current user" do
          before do
            @controller.stub!(:other_user).and_return(@follower1)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have 'accept friend request' in the body" do
            @response.body.should include(I18n.t('muck.friends.acccept_friend_request', :user => @follower1.display_name)
          end
        end
      end
      
      describe "enable_following is true and enable_friending is false" do
        before do
          MuckFriends.configuration.enable_following = true
          MuckFriends.configuration.enable_friending = false
        end
        describe "no current user" do
          before do
            @controller.stub!(:current_user).and_return(nil)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have login/signup in the body" do
            @response.body.should include(I18n.t('muck.friends.login')
          end
        end
        describe "current user is not following other user" do
          before do
            @other_user = Factory(:user)
            @controller.stub!(:other_user).and_return(@other_user)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have 'follow' in the body" do
            @response.body.should include(I18n.t('muck.friends.start_following', :user => @other_user.display_name)
          end
        end
        describe "current user is following the other user" do
          before do
            @being_followed = Factory(:user)
            @aaron.follow(@being_followed)
            @controller.stub!(:other_user).and_return(@being_followed)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have 'stop following' in the body" do
            @response.body.should include(I18n.t('muck.friends.stop_following', :user => @being_followed.display_name)
          end
        end
        describe "current user is not friend with other user, but other user follows current user" do
          before do
            @controller.stub!(:other_user).and_return(@follower1)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have 'follow' in the body" do
            @response.body.should include(I18n.t('muck.friends.start_following', :user => @follower1.display_name)
          end
        end
      end
      
      describe "enable_following is false and enable_friending is true" do
        before do
          MuckFriends.configuration.enable_following = false
          MuckFriends.configuration.enable_friending = true
        end
        describe "no current user" do
          before do
            @controller.stub!(:current_user).and_return(nil)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have login/signup in the body" do
            @response.body.should include(I18n.t('muck.friends.login')
          end
        end
        describe "current user is not friends with the other user" do
          before do
            @other_user = Factory(:user)
            @controller.stub!(:other_user).and_return(@other_user)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have 'friend request' in the body" do
            @response.body.should include(I18n.t('muck.friends.friend_request_prompt', :user => @other_user.display_name)
          end
        end
        describe "current user has sent a friend request to the other user" do
          before do
            @being_followed = Factory(:user)
            @aaron.follow(@being_followed)
            @controller.stub!(:other_user).and_return(@being_followed)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have 'friend request pending' in the body" do
            @response.body.should include(I18n.t('muck.friends.friend_request_pending', :link => '')
          end
        end
        describe "current user is not friend with other user, but other user has sent a friend request" do
          before do
            @controller.stub!(:other_user).and_return(@follower1)
            get :friend_link
          end
          it { should respond_with :success }
          it { should render_template :friend_link }
          it "should have 'accept friend request' in the body" do
            @response.body.should include(I18n.t('muck.friends.acccept_friend_request', :user => @follower1.display_name)
          end
        end
      end
      
    end

    describe "all friends" do
      before do
        get :all_friends
      end
      it { should respond_with :success }
      it { should render_template :all_friends }
    end

    describe "mutual friends" do
      before do
        get :mutual_friends
      end
      it { should respond_with :success }
      it { should render_template :mutual_friends }
    end
    
    describe "friends" do
      before do
        get :friends
      end
      it { should respond_with :success }
      it { should render_template :friends }
    end
    
    describe "followers" do
      before do
        get :followers
      end
      it { should respond_with :success }
      it { should render_template :followers }
    end
    
    describe "followings" do
      before do
        get :followings
      end
      it { should respond_with :success }
      it { should render_template :followings }
    end
    
    describe "friend requests" do
      before do
        @enable_following = MuckFriends.configuration.enable_following
        MuckFriends.configuration.enable_following = false
        get :friend_requests
      end
      after do
        MuckFriends.configuration.enable_following = @enable_following
      end
      it { should respond_with :success }
      it { should render_template :friend_requests }
    end
    
  end
end