#!/usr/bin/env ruby

require 'sqlite3'
require 'active_record'
require 'erb'
require 'date'
require 'optparse'
begin
  require_relative 'db/config'
rescue LoadError
  abort "db/config.rb is missing. See db/config-EXAMPLE.rb."
end
require_relative 'lib/book_culture_lib'

#TODO: Rename this file to 'generate_report' (or something) since it does more
#       than just show.


# Parse all the options before doing anything else.
# -------------------------------------------------

# Set default options
options = {
  :interval => :daily,
  :format => :html,
  :verbose => false,
  :days => :all
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"

  opts.separator ""
  opts.separator "Specific options:"

  opts.on("-i", "--interval INTERVAL", [:daily, :weekly, :monthly, :yearly],
          "The smallest time period to display in report",
          "  (daily, weekly, monthly, yearly)") do |i|
    options[:interval] = i
  end

  opts.on("-s", "--skus sku1,sku2,sku3", Array,
          "Include only specific skus in report") do |list|
    options[:skus] = list
  end

  opts.on("-f", "--format TYPE", [:html, :csv, :tsv],
          "The format of output to generate", "  (html, csv, tsv)") do |t|
    options[:format] = t
  end

  opts.on("-o", "--output FILENAME", "The name of the file to output to",
          "  (if none specified, outputs to stdout)") do |f|
    options[:output] = f
  end

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  #opts.on("--days-ago DAYS", Integer, "Final day of report [default 0]") do |d|
  #  options[:days_ago] = d
  #end

  opts.separator ""
  opts.separator "Exclusive options:"

  opts.on("-d", "--days DAYS", Integer, "Length of report in days") do |d|
    options[:days] = d
  end

  opts.on("-w", "--weeks WEEKS", Integer, "Length of report in weeks") do |w|
    options[:days] = w * 7
  end

  opts.on("-m", "--months MONTHS", Integer, "Length of report in months") do |m|
    options[:days] = m * 30
  end

  opts.on("-y", "--years YEARS", Integer, "Length of report in years") do |y|
    options[:days] = y * 365
  end

  opts.on("-a", "--all", "Report on entire timespan in database") do |a|
    #TODO: put this in terms of start_date! (or :days?)
    options[:days] = :all
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



# Act on the options that were parsed.
# ------------------------------------

ActiveRecord::Base.establish_connection(MyConfig::CONFIG)

#FIXME: Need a better method of handling this...
if !BookCultureLib::AmazonOrder.any?
  raise "Couldn't generate order report : No orders"
end


if options[:days] == :all
  start_date = BookCultureLib::AmazonOrder.first.purchase_date.to_date
else
  start_date = BookCultureLib::AmazonOrder.last.purchase_date.to_date - options[:days]
end
end_date = BookCultureLib::AmazonOrder.last.purchase_date.to_date


my_report = BookCultureLib::Report.new(options[:interval], start_date, end_date, options[:skus])

if options[:output]
  $stderr.puts "Sorry, file output is not supported yet."
else
  puts my_report
end

