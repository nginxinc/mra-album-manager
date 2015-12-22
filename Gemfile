source 'http://rubygems.org'
 
gem 'sinatra'
gem 'activerecord'
gem 'sinatra-activerecord'
gem 'sinatra-reloader'
gem 'json'
 
group :development, :test do
  gem 'better_errors'
  gem 'sqlite3'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl', '~> 4.0'
  gem 'rspec'
end
 
group :production do
  gem 'mysql2'
end