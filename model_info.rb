#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require 'optparse'
begin
  require_relative 'db/config'
rescue LoadError
  abort "db/config.rb is missing. See db/config-EXAMPLE.rb."
end
require_relative 'lib/book_culture_lib'

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"

  opts.on("-a", "--all", "Display all info in db [warning: lots of text]") do |a|
    options[:all] = a
  end

  opts.on("-q", "--quiet", "Supress confirmation prompt for --all") do |q|
    options[:quiet] = q
  end
end.parse!

puts  # yay formatting.

if options[:all]
  if not(options[:quiet])
    print "Are you sure you want to display ALL records? (Type 'yes' if so.): "
    input = gets.strip

    if input.downcase != 'yes'
      exit 1
    end

    puts  # yay formatting.
  end
end

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

puts  # yay formatting.

if options[:all]
  p BookCultureLib::AmazonOrder.all
  puts  # yay formatting.
end

