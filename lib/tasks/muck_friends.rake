require 'fileutils'

namespace :muck do
  namespace :sync do
    desc "Sync files from muck friends."
    task :friends do
      path = File.join(File.dirname(__FILE__), *%w[.. ..])
      system "rsync -ruv #{path}/db ."
    end
  end
end