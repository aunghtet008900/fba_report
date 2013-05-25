#!/usr/bin/env ruby
require 'sqlite3'
require 'active_record'
require 'irb'
require 'csv'
require 'date'
require 'optparse'
begin
  require_relative 'db/config'
rescue LoadError
  abort "db/config.rb is missing. See db/config-EXAMPLE.rb."
end
require_relative 'lib/book_culture_lib'
require_relative 'lib/csv'  # MUST come after requiring 'csv'

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)

puts "#"
puts "# OK, you can now access the activerecord object:"
puts "#    BookCultureLib::AmazonOrder"
puts "# (and all the other neat stuff from this project)"
puts "#"
IRB.start
