source 'https://rubygems.org'
ruby '3.3.1'

gem 'activesupport', '~> 7.1', '>= 7.1.3.2', require: 'active_support/all'
gem 'aws-sdk-sqs', '~> 1.93'
gem 'bugsnag', '~> 6.26', '>= 6.26.4'
gem 'cinch', git: 'https://github.com/blolol/cinch', tag: 'v2.3.5'
gem 'connection_pool', '~> 2.4', '>= 2.4.1'
gem 'dotenv'
gem 'harby', '~> 1.2.0'
gem 'mongoid', '~> 8.1', '>= 8.1.5'
gem 'pry'
gem 'rake'
gem 'redis', '~> 5.2'

# These gems are dependencies of polyglot 0.3.5, which is a dependency
# of treetop 1.6.x, which is a dependency of harby 1.2. They were
# removed from Ruby's standard library in Ruby 2.7, and released as gems.
# If polyglot is updated to specify the gems as dependencies, then these
# explicit dependencies can be removed from Wheaties' Gemfile.
gem 'e2mmap'
gem 'thwait'

group :commands do
  gem 'aws-sdk-s3', '~> 1.182'
  gem 'chronic_duration', '~> 0.10.6'
  gem 'engtagger', '~> 0.4.0'
  gem 'http', '~> 5.2'
  gem 'httparty', '~> 0.21.0'
  gem 'nokogiri', '~> 1.16'
  gem 'terrapin', '~> 1.0.1'
  gem 'transloadit', '~> 3.1.0'
end

group :test do
  gem 'rspec', '~> 3.7.0'
end
