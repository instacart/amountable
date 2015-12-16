lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'amountable/version'

Gem::Specification.new do |gem|
  gem.name          = 'amountable'
  gem.version       = Amountable::VERSION
  gem.authors       = ['Emmanuel Turlay']
  gem.email         = %w(emmanuel@instacart.com)
  gem.description   = %q{With Amountable, you can easily attach, organize and sum Ruby money fields to your models without migrating.}
  gem.summary       = 'Easy Money fields for your Rails models.'
  gem.homepage      = 'https://github.com/instacart/amountable'
#  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^spec/})
  gem.require_paths = ['lib']
  gem.required_ruby_version     = '>= 2.1.1'

  gem.add_dependency 'rails', '~> 4.2'
  #gem.add_dependency 'activerecord', ['>= 4.2', '< 5']
  gem.add_dependency 'activerecord-import', '0.10.0'
  gem.add_dependency 'money-rails'
  gem.add_dependency 'monetize'

  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'mysql2'
  gem.add_development_dependency 'pg'

  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'db-query-matchers'
end
