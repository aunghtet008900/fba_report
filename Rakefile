#!/usr/bin/env rake

require 'sqlite3'
require 'active_record'
require_relative 'db/config'
require_relative 'lib/book_culture_lib'


# A simple little rakefile to provide a few rails-like tasks.
#
# Note: this is currently hardcoded to this specific project.

task :default do
  puts "Available tasks:"
  system("rake -sT")  # s for silent
end


namespace :db do

  desc "Migrate the db"
  task :migrate do
    ActiveRecord::Base.establish_connection(MyConfig::CONFIG)
    ActiveRecord::Migrator.migrate File.expand_path('../db/migrate/', __FILE__)
  end

  desc "Drop the db"
  task :drop do
    ActiveRecord::Base.establish_connection(MyConfig::CONFIG)
    drop_database_and_rescue(MyConfig::CONFIG)
  end

  desc "Reset the db"
  task :reset do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:migrate'].invoke
  end

  desc "Show info about all tables in db"
  task :info do
    ActiveRecord::Base.establish_connection(MyConfig::CONFIG)
    list_database_table_simple_schema(MyConfig::CONFIG)
  end

end



def drop_database(config)
  case config[:adapter]
  when /sqlite/
    FileUtils.rm(MyConfig::CONFIG[:database])
  else
    raise "This Rakefile can't handle your database type."
  end
end

def drop_database_and_rescue(config)
  begin
    drop_database(config)
  rescue Exception => e
    $stderr.puts "Couldn't drop #{config[:database]} : #{e.inspect}"
  end
end


def trimpad(str, width)
  (str.to_s + (" " * width))[0..width]
end


def list_database_table_simple_schema(config)
  case config[:adapter]
  when /sqlite/
    # For now this feels kind of hack-y, since it's a lot of low-level sql.
    # Not sure if there's a better, more proper way to do this?

    sql = <<-SQL
      SELECT name
      FROM sqlite_master
      WHERE type = 'table' AND NOT name = 'sqlite_sequence'
    SQL

    tables = ActiveRecord::Base.connection.execute(sql)

    #TODO: Break some of this table stuff out into its own method
    #       - return just a simple array of table names
    #       - then there's no need for res['name'] everywhere
    #
    #TODO: Break some of the pragma stuff out into its own method
    #
    #TODO: Get a datastructure (simple little hash) from the table and pragma,
    #       then, with another method, display the shit

    tables.each do |res|
      sql = "PRAGMA table_info(%s);" % [ res['name'] ]
      myprag = ActiveRecord::Base.connection.execute(sql)
      puts # Yay formatting.
      puts "TABLE #{res["name"]} columns:"

      puts "  #{trimpad("cid",3)} #{trimpad("name",25)} #{trimpad("type",20)}"
      puts "  #{trimpad("---",3)} #{trimpad("----",25)} #{trimpad("----",20)}"
      myprag.each do |item|
        prag_cid = trimpad(item['cid'],3)
        prag_name = trimpad(item['name'],25)
        prag_type = trimpad(item['type'],20)
        puts "  #{prag_cid} #{prag_name} #{prag_type}"
      end

      sql = "SELECT count(*) FROM %s;" % [ res['name'] ]
      mycount = ActiveRecord::Base.connection.execute(sql)[0]["count(*)"]
      puts "Records in table: #{mycount}"
    end

    puts # Yay formatting.
  else
    raise "This Rakefile can't handle your database type."
  end

end
