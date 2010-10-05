require File.dirname(__FILE__) + '/../spec_helper'

describe Muck::FriendsController do
  
  before do
    @quentin = Factory(:user)
    @aaron = Factory(:user)
  end
  
  describe "not logged in" do
    describe "render index page" do
      before do
        get :index, :user_id => @quentin.to_param
      end
      it { should respond_with :success }
      it { should render_template :index }
    end
    
    describe "deny access to create" do
      before do
        post :create, { :id => @aaron.to_param }
      end
      it { should redirect_to( login_path ) }
      it { should set_the_flash.to(I18n.t("muck.users.login_requred")) }
    end
    
    describe "deny access to destroy" do
      before do
        delete :destroy, { :id => @aaron.to_param }
      end
      it { should redirect_to( login_path ) }
      it { should set_the_flash.to(I18n.t("muck.users.login_requred")) }
    end
  end

  describe "logged in" do
    before do
      activate_authlogic
      login_as @quentin
    end
    
    describe "render my index page" do
      before do
        get :index, :user_id => @quentin.to_param
      end
      it { should respond_with :success }
      it { should render_template :index }
    end
    
    describe "render another user's friend page" do
      before do
        get :index, :user_id => @aaron.to_param
      end
      it { should respond_with :success }
      it { should render_template :index }
    end
    
    describe "make a follower (same as send friend request)" do
      before do
        Friend.destroy_all
        post :create, { :id => @aaron.to_param, :format=>'js' }
      end
      it { should respond_with :success }
      it { should_not set_the_flash }
      it "should setup relationship" do
        @quentin.reload
        @aaron.reload
        @quentin.should_not be_friend_of(@aaron)
        @quentin.should be_following(@aaron)
        @aaron.should be_followed_by(@quentin)
      end
    end
    
    describe "make a friendship" do
      before do
        Friend.destroy_all
        Friend.add_follower(@quentin, @aaron)
        post :create, { :id => @aaron.to_param, :format=>'js'}
      end
      it { should respond_with :success }
      it { should_not set_the_flash }
      it "should setup friend relationship" do
        @quentin.reload
        @aaron.reload
        @quentin.should be_friend_of(@aaron)
        @quentin.should_not be_followed_by(@aaron)
        @aaron.should be_friend_of(@quentin)
        @aaron.should_not be_followed_by(@quentin)
      end
    end

    describe "update - block user" do
      before do
        Friend.destroy_all
        Friend.add_follower(@quentin, @aaron)
        Friend.make_friends(@quentin, @aaron)
        post :update, { :id => @aaron.to_param, :block => true, :format=>'js'}
      end
      it { should respond_with :success }
      it { should_not set_the_flash }
      it "should block user" do
        @quentin.reload
        @aaron.reload
        @quentin.blocked?(@aaron).should be_true
      end
    end

    describe "update - unblock user" do
      before do
        Friend.destroy_all
        Friend.add_follower(@quentin, @aaron)
        Friend.make_friends(@quentin, @aaron)
        @quentin.block_user(@aaron)
        post :update, { :id => @aaron.to_param, :unblock => true, :format=>'js' }
      end
      it { should respond_with :success }
      it { should_not set_the_flash }
      it "should unblock user" do
        @quentin.reload
        @aaron.reload
        @quentin.blocked?(@aaron).should be_false
      end
    end
    
    describe "error while trying to make an invalid friendship" do
      before do
        Friend.destroy_all
        post :create, { :id => @quentin.to_param, :format => 'js' }
      end
      it { should respond_with :success }
      it { should_not set_the_flash }
      it "should not create friendship" do
        @quentin.reload
        @aaron.reload
        @quentin.friend_of?(@aaron).should be_false
      end
    end
    
    describe "Following allowed" do
      before do
        @temp_enable_following = MuckFriends.configuration.enable_following
        MuckFriends.configuration.enable_following = true
        Friend.destroy_all
        @aaron.follow(@quentin)
        @quentin.become_friends_with(@aaron)
      end
      after do
        MuckFriends.configuration.enable_following = @temp_enable_following
      end
      describe "DELETE to destroy js request" do
        before do
          delete :destroy, { :user_id => @quentin.to_param, :id => @aaron.to_param, :format => 'js'}
        end
        it { should respond_with :success }
        it "stop friendship" do
          @quentin.reload
          @aaron.reload
          @quentin.should_not be_friend_of(@aaron)
          @quentin.should_not be_following(@aaron)
          @quentin.should be_followed_by(@aaron)
        end
      end
      describe "DELETE to destroy  html request" do
        before do
          delete :destroy, { :user_id => @quentin.to_param, :id => @aaron.to_param}
        end
        it { should redirect_to( profile_path(@aaron) ) }
      end
    end
    
    describe "Following not allowed" do
      before do
        @temp_enable_following = MuckFriends.configuration.enable_following
        MuckFriends.configuration.enable_following = false
        Friend.destroy_all
        @aaron.follow(@quentin)
        @quentin.become_friends_with(@aaron)          
      end
      after do
        MuckFriends.configuration.enable_following = @temp_enable_following
      end
      describe "js request" do
        before do
          delete :destroy, { :user_id => @quentin.to_param, :id => @aaron.to_param, :format => 'js'}
        end
        it { should respond_with :success }
        it "should stop being friends and not allow following" do
          @quentin.reload
          @aaron.reload
          @aaron.should_not be_followed_by(@quentin)
          @quentin.should_not be_followed_by(@aaron)
          @aaron.should_not be_friend_of(@quentin)
          @quentin.should_not be_friend_of(@aaron)
          @aaron.should_not be_following(@quentin)
          @quentin.should_not be_following(@aaron)
        end
      end
    end
  
  end
end