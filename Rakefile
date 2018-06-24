namespace :docker do
  desc 'Build the Wheaties Docker image'
  task :build do
    require_relative './lib/wheaties/version'
    version_tag = "wheaties:#{Wheaties::VERSION}"
    sh "docker build -t wheaties -t #{version_tag} ."
  end

  desc 'Run the Wheaties Docker image in interactive mode'
  task :run do
    sh 'docker run --rm -i --env-file=docker.env wheaties'
  end
end
