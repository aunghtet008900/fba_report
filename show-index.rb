#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require_relative 'db/config.rb'
require_relative 'lib/gem_example'

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)

# this class definition should be moved into lib/gem_example/employee.rb
class Employee < ActiveRecord::Base
end


Employee.all.each do |emp|
  puts "#{emp.id} #{emp.name} #{emp.created_at}"
end

puts

puts "The attributes:"
puts Employee.attribute_names

