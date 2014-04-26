spec = Gem::Specification.new do |s|
  s.name = 'wheaties-grunt'
  s.version = '1.1.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Ross Paffett']
  s.email = ['ross@rosspaffett.com']
  s.homepage = 'https://github.com/raws/wheaties-grunt'
  s.summary = 'User-authored IRC bot'
  s.description = 'An IRC bot whose functionality is defined by its users.'
  s.license = 'MIT'
  s.files = Dir['lib/**/*.rb']
  s.require_path = 'lib'

  s.add_runtime_dependency 'mongo_mapper', '~> 0.12.0'
  s.add_runtime_dependency 'treetop', '~> 1.4.10'
  s.add_runtime_dependency 'wheaties', '>= 1.0.0'
end
