#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require 'yaml'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => File.expand_path('../db/production.sqlite3', __FILE__)
)


#take the version from the command line, or use nil if there is no command line argument
ActiveRecord::Migrator.migrate File.expand_path('../db/migrate/', __FILE__), ARGV[0] ? ARGV[0].to_i : nil

