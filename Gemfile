source 'https://rubygems.org'
ruby '3.4.7'

gem 'activesupport', require: 'active_support/all'
gem 'aws-sdk-sqs', '~> 1'
gem 'bugsnag', '~> 6.26', '>= 6.26.4'
gem 'cinch', git: 'https://github.com/blolol/cinch', tag: 'v2.3.5'
gem 'connection_pool'
gem 'csv'
gem 'dotenv'
gem 'harby', '~> 1.2.0'
gem 'mongoid', '~> 8.1', '>= 8.1.5'
gem 'ox'
gem 'pry'
gem 'rake'
gem 'redis'
gem 'treetop', '<= 1.6.12'

# These gems are dependencies of polyglot 0.3.5, which is a dependency
# of treetop 1.6.x, which is a dependency of harby 1.2. They were
# removed from Ruby's standard library in Ruby 2.7, and released as gems.
# If polyglot is updated to specify the gems as dependencies, then these
# explicit dependencies can be removed from Wheaties' Gemfile.
gem 'e2mmap'
gem 'thwait'

group :commands do
  gem 'aws-sdk-s3', '~> 1'
  gem 'chronic_duration'
  gem 'cloudinary'
  gem 'engtagger'
  gem 'http'
  gem 'httparty'
  gem 'mime-types', require: 'mime/types'
  gem 'terrapin'
  gem 'transloadit'
end

group :test do
  gem 'rspec', '~> 3.7.0'
end
