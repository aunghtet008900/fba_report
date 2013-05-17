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
  :all => true,
  :span_day => 0,
  :offset_day => 0,
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options]"

  opts.separator ""
  opts.separator "Spans and offsets (can be combined):"

  opts.on("-d", "--span-day DAYS", Integer, "Length of report in days") do |d|
    options[:span_day] += d
    options[:all] = false
  end

  opts.on("-w", "--span-week WEEKS", Integer, "Length of report in weeks") do |w|
    options[:span_day] += w * 7
    options[:all] = false
  end

  opts.on("-m", "--span-month MONTHS", Integer, "Length of report in months") do |m|
    options[:span_day] += (m * 30)
    options[:all] = false
  end

  opts.on("-y", "--span-year YEARS", Integer, "Length of report in years") do |y|
    options[:span_day] += (y * 365)
    options[:all] = false
  end

  opts.on("--offset-day DAYS", Integer, "Offset of report in days") do |d|
    options[:offset_day] += d
    options[:all] = false
  end

  opts.on("--offset-week WEEKS", Integer, "Offset of report in weeks") do |w|
    options[:offset_day] += (w * 7)
    options[:all] = false
  end

  opts.on("--offset-month MONTHS", Integer, "Offset of report in months") do |m|
    options[:offset_day] += (m * 30)
    options[:all] = false
  end

  opts.on("--offset-year YEARS", Integer, "Offset of report in years") do |y|
    options[:offset_day] += (y * 365)
    options[:all] = false
  end

  opts.separator ""
  opts.separator "Misc options:"

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

  opts.on("-a", "--all", "Report on entire timespan in database",
          "  (overrides spans and offsets)") do |a|
    options[:all] = a
  end

  opts.on("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.on("--dry-run", "Only show start and end dates, no report") do |d|
    options[:dry_run] = d
  end

  ## Another typical switch to print the version.
  #opts.on_tail("--version", "Show version") do
  #  puts OptionParser::Version.join('.')
  #  exit
  #end

end.parse!



# Act on the options that were parsed.
# ------------------------------------

$stderr.puts "Start report generation..."
ActiveRecord::Base.establish_connection(MyConfig::CONFIG)

#FIXME: Need a better method of handling this...
if !BookCultureLib::AmazonOrder.any?
  #raise "Couldn't generate order report : No orders"
  abort "Couldn't generate order report : No orders"
end


if options[:all]
  start_date = BookCultureLib::AmazonOrder.first.purchase_date.to_date
  end_date = BookCultureLib::AmazonOrder.last.purchase_date.to_date
else
  #start_date = BookCultureLib::AmazonOrder.last.purchase_date.to_date - options[:span_day]
  start_date = Date.today - options[:offset_day] - options[:span_day]
  end_date = Date.today - options[:offset_day]
end
#end_date = BookCultureLib::AmazonOrder.last.purchase_date.to_date


my_report = BookCultureLib::Report.new(options[:interval], start_date, end_date, options[:skus])
$stderr.puts "Done."

if options[:dry_run]
  puts "start: #{start_date}"
  puts "end:   #{end_date}"
  exit
end

if options[:output]
  #TODO: Make this save safely, ask about overwriting, etc
  File.open(options[:output], 'w+') do |f|
    f.puts my_report
  end
else
  puts my_report
end

