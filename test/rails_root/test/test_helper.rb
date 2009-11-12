$:.reject! { |e| e.include? 'TextMate' }
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
gem 'muck-engine'
require 'muck_test_helper'
require 'authlogic/test_case'

class ActiveSupport::TestCase
  include MuckTestMethods
  include Authlogic::TestCase
end