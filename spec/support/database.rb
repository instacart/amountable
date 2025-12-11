# Copyright 2015-2021, Instacart

require "activerecord-import/base"

db_name = ENV['DB'] || 'postgresql'
spec_dir = Pathname.new(File.dirname(__FILE__)) / '..'
database_yml = spec_dir.join('internal/config/database.yml')

fail "Please create #{database_yml} first to configure your database. Take a look at: #{database_yml}.sample" unless File.exist?(database_yml)

ActiveRecord::Migration.verbose = false
ActiveRecord.try(:default_timezone=, :utc) || ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.configurations = YAML.load_file(database_yml)
ActiveRecord::Base.logger = Logger.new(File.join(__dir__, '../debug.log'))
ActiveRecord::Base.logger.level = ENV['CI'] ? ::Logger::ERROR : ::Logger::DEBUG
configs = ActiveRecord::Base.configurations
config = configs.try(:find_db_config, db_name) || configs[db_name]

begin
  ActiveRecord::Base.establish_connection(db_name.to_sym)
  ActiveRecord::Base.connection
rescue
  case db_name
  when /mysql/
    ActiveRecord::Base.establish_connection(config.merge('database' => nil))
    ActiveRecord::Base.connection.create_database(config['database'], {charset: 'utf8', collation: 'utf8_unicode_ci'})
  when 'postgresql'
    ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
    ActiveRecord::Base.connection.create_database(config['database'], config.merge('encoding' => 'utf8'))
  end

  ActiveRecord::Base.establish_connection(config)
end

def jsonb_available?
  true
end

require_relative '../internal/db/schema'

Dir[spec_dir.join('internal/app/models/*.rb')].each { |file| require_relative file }
