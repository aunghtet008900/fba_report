#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require_relative 'db/config.rb'
require_relative 'lib/gem_example'

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)


# this class definition should be moved into lib/gem_example/employee.rb
class Employee < ActiveRecord::Base
end

#emp = Employee.new(name:"John Doe", salary:"$10.00", role:"grunt")
#emp.save

puts "adding employee..."
Employee.create(name:"John Doe", salary:"$10.00", role:"grunt")
puts "adding employee..."
Employee.create(name:"Jane Doe", salary:"$20.00", role:"grunt")
puts "adding employee..."
Employee.create(name:"Jack Doe", salary:"$30.00", role:"n/a")

puts
puts "current number of employees:"
puts Employee.count


