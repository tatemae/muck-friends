require 'rake'
require 'rake/tasklib'
require 'fileutils'

module MuckFriends
  class Tasks < ::Rake::TaskLib
    def initialize
      define
    end
  
    private
    def define
      
      namespace :muck do
        namespace :sync do
          desc "Sync files from muck friends."
          task :friends do
            path = File.join(File.dirname(__FILE__), *%w[.. ..])
            system "rsync -ruv #{path}/db ."
          end
        end
      end
      
    end
  end
end
MuckFriends::Tasks.new