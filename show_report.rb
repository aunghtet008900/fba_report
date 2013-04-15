#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require 'erb'
require 'date'
require_relative 'db/config'
require_relative 'lib/book_culture_lib'

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)


# ----------------------------------------
# Generate the data structure from queries
# ----------------------------------------



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


# -----------------------------
# Generate html using templates
# -----------------------------

#require 'pp'    #DEBUG
#pp report_data  #DEBUG

## PSEUDOCODE:
#      report_data.each do |day|
#        start a row
#        fba_skus.each do |sku|
#          make a cell based on the day[:quantities][sku]
#        end
#        finish a row
#      end



template = %{
  <html>
    <head><title>Generated on <%= @date_generated %></title></head>
    <style>
      .table {
        border: 1px solid #666666;
        border-collapse: collapse;
      }
      .table th {
        border: 1px solid #666666;
        padding: 8px;
        background-color: #dedede;
      }
      .table td {
        border: 1px solid #666666;
        padding: 8px;
        background-color: #ffffff;
      }
    </style>
    <body>

      <h1>Generated on <%= @date_generated %></h1>

      <table class="table">
        <tr>
          <th>Day</th>
          <% @all_skus.each do |sku| %>
            <th><%= sku %></th>
          <% end %>
        </tr>
        <% @days.each do |day| %>
          <tr>
            <td><%= day[:date] %></td>
            <% @all_skus.each do |sku| %>
              <td><%= day[:quantities][sku] %></td>
            <% end %>
          </tr>
        <% end %>
      </table>

    </body>
  </html>
}.gsub(/^  /, '')
#The gsub is just to remove the first two spaces on each line.
# It should be removed when you end up reading this from a file.

#TODO: Read the template from a file, instead.

rhtml = ERB.new(template)

puts rhtml.result(report_data.get_binding)
#TODO: Output html to a file, instead of stdout
#       (although having a stdout option might be nice...)

