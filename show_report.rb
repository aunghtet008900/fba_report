#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require 'erb'
require 'date'
require_relative 'db/config'
require_relative 'lib/book_culture_lib'

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)

# Will be used for generating a table:
fba_skus = BookCultureLib::AmazonOrder.uniq.pluck(:sku)
#TODO: Might be better to do a .where with the start and end of range, then do a pluck from that, so we're only listing fba skus that exist in the desired range.
#(Make this some sort of configurable option!)


report_data = BookCultureLib::ReportData.new( Time.now.to_s, fba_skus )


# PSEUDOCODE:
#
#   days.each
#     orders.each
#       put the item into a blank items hash
#       put the hash into an array
#     end
#   end

# These variables are just for clarity's sake in the .each part later
start_date = BookCultureLib::AmazonOrder.last.purchase_date.to_date - 14
end_date = BookCultureLib::AmazonOrder.last.purchase_date.to_date

#Generate the data structure from queries
(start_date..end_date).each do |day|
  start_of_day = day
  end_of_day = day + 1
  temp_hash = { date: day, quantities: Hash.new(0) }

  BookCultureLib::AmazonOrder.where("purchase_date >= :start_date AND purchase_date < :end_date",
                                    {:start_date => start_of_day, :end_date => end_of_day}).each do |order|
    temp_hash[:quantities][order.sku] += order.quantity
  end

  report_data << temp_hash
end

#TODO: Move the template path stuff to the config?
template = IO.read(File.expand_path('../views/report_template.html.erb',
                                    __FILE__))
rhtml = ERB.new(template, 0, '>')
# The 0 does nothing special, the '>' eliminates pointless newlines

puts rhtml.result(report_data.get_binding)
#TODO: Output html to a file, instead of stdout
#       (although having a stdout option might be nice...)


