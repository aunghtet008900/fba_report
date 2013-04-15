#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require 'erb'
require_relative 'db/config'
require_relative 'lib/book_culture_lib'

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)


# ----------------------------------------
# Generate the data structure from queries
# ----------------------------------------

# Where the main report data is kept:
report_data = []

# Will be used for generating a table later:
fba_skus = BookCultureLib::AmazonOrder.uniq.pluck(:sku)

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

require 'pp'    #DEBUG
pp report_data  #DEBUG

## PSEUDOCODE:
#      report_data.each do |day|
#        start a row
#        fba_skus.each do |sku|
#          make a cell based on the day[:quantities][sku]
#        end
#        finish a row
#      end


######################################################################################
### The following is all just DEBUG stuff while trying to test out and understand ERB:

# Create template.
#template = ERB.new %{
template = %{
  <html>
    <head><title>Ruby Toys -- <%= @name %></title></head>
    <body>

      <h1><%= @name %></h1>
      <p><%= @desc %></p>

       <ul>
        <% @features.each do |f| %>
          <li><b><%= f %></b></li>
        <% end %>
      </ul>

    </body>
  </html>
}.gsub(/^  /, '')

#TODO: Read the template from a file, instead.

rhtml = ERB.new(template)

#TODO: Design a class that I'll use for the reports.
#       (Hell, you can even figure a few classes out, so you can do different kinds of reports.)
#
#TODO: Move the class to a different file.

class Product
  def initialize( name, desc )
    @name = name
    @desc = desc
    @features = []
  end

  def add_feature( feature )
    @features << feature
  end

  def get_binding
    binding
  end
end

toy = Product.new( "Rubysapien", "Geek's Best Friend!")
toy.add_feature("Listens for verbal commands in the Ruby language!")
toy.add_feature("Ignores Perl, Java, and all C variants.")


puts rhtml.result(toy.get_binding)
#TODO: Output html to a file, instead of stdout
#       (although having a stdout option might be nice...)


