#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require_relative 'db/config'
require_relative 'lib/book_culture_lib'

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)

#TODO: Make this be an option:
## Show all orders:
#BookCultureLib::AmazonOrder.all.each do |ord|
#  puts ord
#end

puts

puts "The attributes:"
BookCultureLib::AmazonOrder.attribute_names.each do |atr|
  puts "  " + atr.to_s
end

puts "Number of database records:"
puts "  " + BookCultureLib::AmazonOrder.count.to_s
if BookCultureLib::AmazonOrder.first
  puts "first purchase date:"
  puts "  " + BookCultureLib::AmazonOrder.first.purchase_date.to_s
  puts "last purchase date:"
  puts "  " + BookCultureLib::AmazonOrder.last.purchase_date.to_s
end

puts
