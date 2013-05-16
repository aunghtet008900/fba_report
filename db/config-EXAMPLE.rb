# Please copy this file to config.rb and change these config options to
# whatever you want ActiveRecord to use.

module MyConfig
  CONFIG = {
            :adapter => 'sqlite3',
            :database => 'production.sqlite3',
            :pool => 5,
            :timeout => 5000
  }
end
