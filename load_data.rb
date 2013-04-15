#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require 'csv'
require 'date'
require_relative 'db/config'
require_relative 'lib/book_culture_lib'
require_relative 'lib/csv'  # MUST come after requiring 'csv'

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)


#the_file = File.join("_SAMPLE_DATA","sample-input.txt")
#the_file = File.join("_SAMPLE_DATA","sample-mangled-input.txt")
the_file = ARGV[0]

csv_args = {
  :headers => true,
  :col_sep => "\t",
  :skip_blanks => false,
  :header_converters => :amazon_symbol
}

CSV.foreach(the_file, csv_args) do |row|

  BookCultureLib::AmazonOrder.where(amazon_order_id: row[:amazon_order_id]).
                              first_or_create(purchase_date: DateTime.parse(row[:purchase_date]),
                                              fulfillment_channel: row[:fulfillment_channel],
                                              product_name: row[:product_name],
                                              sku: row[:sku],
                                              asin: row[:asin],
                                              quantity: row[:quantity],
                                              item_price: row[:item_price],
                                              ship_postal_code: row[:ship_postal_code],
                                              ship_country: row[:ship_country]
  )

  # If you just use .create() instead of .where().first_or_create(),
  # duplicates just silently fail and it moves on to the next item when dupes
  # exist. Might be faster...?

end
