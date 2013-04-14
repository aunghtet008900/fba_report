#!/usr/bin/env rake

require 'sqlite3'
require 'active_record'
require_relative 'db/config'
require_relative 'lib/book_culture_lib'


# A simple little rakefile to provide a few rails-like tasks.
#
# Note: this is currently hardcoded to this specific project.

namespace :db do

  desc "Migrate the db"
  task :migrate do
    ActiveRecord::Base.establish_connection(MyConfig::CONFIG)
    ActiveRecord::Migrator.migrate File.expand_path('../db/migrate/', __FILE__)
  end

  desc "Drop the db"
  task :drop do
    ActiveRecord::Base.establish_connection(MyConfig::CONFIG)
    drop_database_and_rescue(MyConfig::CONFIG)
  end

  desc "Reset the db"
  task :reset do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:migrate'].invoke
  end

end



def drop_database(config)
  case config[:adapter]
  when /sqlite/
    FileUtils.rm(MyConfig::CONFIG[:database])
  else
    raise "This Rakefile can't handle your database type."
  end
end

def drop_database_and_rescue(config)
  begin
    drop_database(config)
  rescue Exception => e
    $stderr.puts "Couldn't drop #{config[:database]} : #{e.inspect}"
  end
end

