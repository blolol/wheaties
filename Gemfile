source 'https://rubygems.org'
ruby '2.7.6'

gem 'activesupport', '~> 5.2.4', require: 'active_support/all'
gem 'aws-sdk-sqs', '~> 1.51'
gem 'bugsnag', '~> 6.13.0'
gem 'cinch', git: 'https://github.com/blolol/cinch', branch: 'wheaties'
gem 'connection_pool', '~> 2.2.2'
gem 'dotenv'
gem 'harby', '~> 1.2.0'
gem 'mongoid', '~> 7.0'
gem 'pry'
gem 'rake'
gem 'redis', '~> 4.1.3'

# These gems are dependencies of polyglot 0.3.5, which is a dependency
# of treetop 1.6.x, which is a dependency of harby 1.2. They were
# removed from Ruby's standard library in Ruby 2.7, and released as gems.
# If polyglot is updated to specify the gems as dependencies, then these
# explicit dependencies can be removed from Wheaties' Gemfile.
gem 'e2mmap'
gem 'thwait'

group :commands do
  gem 'chronic_duration', '~> 0.10.6'
  gem 'engtagger', '~> 0.2.2'
  gem 'http', '~> 4.4.1'
  gem 'httparty', '~> 0.18.0'
  gem 'nokogiri', '~> 1.13.6'
  gem 'twitter', '~> 7.0.0'
end

group :test do
  gem 'rspec', '~> 3.7.0'
end
