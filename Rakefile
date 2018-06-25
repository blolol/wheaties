require 'shellwords'

namespace :docker do
  desc 'Build the Wheaties Docker image'
  task :build do
    require_relative './lib/wheaties/version'
    version_tag = "wheaties:#{Wheaties::VERSION}"
    sh "docker build -t wheaties -t #{version_tag} ."
  end

  desc 'Run a one-off Wheaties container'
  task :run do
    sh 'docker run --rm -i --env-file=docker.env wheaties'
  end

  namespace :mongo do
    desc 'Restore a dump to the Docker Compose wheaties_development database'
    task :restore, %i(dump_path) do |task, args|
      source_dump_path = File.expand_path(args[:dump_path])
      dest_path = "/tmp/wheaties-restore-#{Time.now.to_i}"
      sh "docker cp #{source_dump_path.shellescape} wheaties_mongodb_1:#{dest_path.shellescape}"
      sh "docker-compose exec mongodb mongorestore -d wheaties_development #{dest_path.shellescape}"
    end
  end
end
