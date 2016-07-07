# Copyright 2015-2016, Instacart

db_name = ENV['DB'] || 'postgresql'
spec_dir = Pathname.new(File.dirname(__FILE__)) / '..'
database_yml = spec_dir.join('internal/config/database.yml')

fail "Please create #{database_yml} first to configure your database. Take a look at: #{database_yml}.sample" unless File.exist?(database_yml)

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.configurations = YAML.load_file(database_yml)
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), '../debug.log'))
ActiveRecord::Base.logger.level = ENV['TRAVIS'] ? ::Logger::ERROR : ::Logger::DEBUG
config = ActiveRecord::Base.configurations[db_name]

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

require_relative '../internal/db/schema'

Dir[spec_dir.join('internal/app/models/*.rb')].each { |file| require_relative file }
