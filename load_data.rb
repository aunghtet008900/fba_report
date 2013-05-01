#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require 'csv'
require 'date'
require 'optparse'
require_relative 'db/config'
require_relative 'lib/book_culture_lib'
require_relative 'lib/csv'  # MUST come after requiring 'csv'


# Parse all the options before doing anything else.
# -------------------------------------------------

# Set default options
options = {
  :force_reimport => false,
  :archive => false,
  :verbose => false
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options] INPUTFILE"

  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-f", "--force", "Force re-importing of pre-existing info") do |f|
    options[:force_reimport] = f
  end

  opts.on("-a", "--[no-]archive", "Archive input file after import") do |a|
    options[:archive] = a
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  opts.separator ""
  opts.separator "Common options:"

  # No argument, shows at tail.  This will print an options summary.
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  ## Another typical switch to print the version.
  #opts.on_tail("--version", "Show version") do
  #  puts OptionParser::Version.join('.')
  #  exit
  #end

end.parse!




ActiveRecord::Base.establish_connection(MyConfig::CONFIG)


#the_file = File.join("_SAMPLE_DATA","sample-input.txt")
#the_file = File.join("_SAMPLE_DATA","sample-mangled-input.txt")
the_file = ARGV[0]
#TODO: Handle multiple files somehow? Either read them or error out.

csv_args = {
  :headers => true,
  :col_sep => "\t",                    # Tabs separate columns.
  :skip_blanks => false,               # Skip blank lines.
  :quote_char => '`',                  # So normal quotes don't mess things up.
  :header_converters => :amazon_symbol # Custom header conversion.
}

before_count = BookCultureLib::AmazonOrder.count
row_count = 0
fba_count = 0

puts "Parsing #{the_file} ..."

CSV.foreach(the_file, csv_args) do |row|

  row_count += 1

  if row[:fulfillment_channel] == 'Amazon'

    fba_count += 1

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
  end

  # If you just use .create() instead of .where().first_or_create(),
  # duplicates just silently fail and it moves on to the next item when dupes
  # exist. Might be faster...?

end

after_count = BookCultureLib::AmazonOrder.count

puts "Done."
puts "Rows read:      #{row_count}"
puts "FBA rows:       #{fba_count}"
puts "FBA rows added: #{after_count - before_count}"


