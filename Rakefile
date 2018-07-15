require 'shellwords'

def wheaties_version_tag
  require_relative './lib/wheaties/version'
  "blolol/wheaties:#{Wheaties::VERSION}"
end

namespace :docker do
  desc 'Build the Wheaties Docker image'
  task :build do
    sh "docker build -t blolol/wheaties:latest -t #{wheaties_version_tag} ."
  end

  desc 'Push the latest Wheaties Docker image to Docker Hub'
  task :push do
    sh "docker push #{wheaties_version_tag}"
    sh "docker push blolol/wheaties:latest"
  end

  desc 'Run a one-off Wheaties container'
  task :run do
    sh 'docker run --rm -i --env-file=docker.env blolol/wheaties'
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
