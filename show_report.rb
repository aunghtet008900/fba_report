#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require_relative 'db/config'
require_relative 'lib/book_culture_lib'

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)


BookCultureLib::AmazonOrder.all.each do |ord|
  puts "#{ord.id} #{ord.product_name} #{ord.purchase_date}"
end

puts

puts "The attributes:"
puts BookCultureLib::AmazonOrder.attribute_names

puts

puts "Number of database records:"
puts BookCultureLib::AmazonOrder.count

