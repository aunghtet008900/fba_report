#!/usr/bin/env ruby

module MyConfig
  CONFIG = {
            :adapter => 'sqlite3',
            :database => File.expand_path('../production.sqlite3', __FILE__),
            :pool => 5,
            :timeout => 5000
  }
end
