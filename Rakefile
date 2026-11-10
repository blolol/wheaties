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

namespace :release do
  desc 'Bump Wheaties::VERSION, commit the change and tag it'
  task :tag do
    version_path = 'lib/wheaties/version.rb'
    require_relative './lib/wheaties/version'
    current_version = Wheaties::VERSION
    major, minor, patch = current_version.split('.')
    default_version = [major, minor, patch.to_i + 1].join('.')

    puts "Current version: #{current_version}"
    print "New version [#{default_version}]: "
    input = $stdin.gets.to_s.strip
    version = input.empty? ? default_version : input.delete_prefix('v')

    unless version.match?(/\A\d+\.\d+\.\d+\z/)
      abort "Invalid version: #{version.inspect} (expected something like 1.2.3)"
    end

    tag = "v#{version}"
    if system("git rev-parse -q --verify refs/tags/#{tag.shellescape} > /dev/null")
      abort "Tag #{tag} already exists"
    end

    other_staged = `git diff --cached --name-only`.split("\n") - [version_path]
    unless other_staged.empty?
      puts 'Warning: other files are already staged:'
      other_staged.each { |file| puts "  #{file}" }
      print 'Cancel? [Y/n] '
      answer = $stdin.gets.to_s.strip.downcase
      abort 'Cancelled' unless answer == 'n' || answer == 'no'
      puts 'Continuing; only the version file will be committed.'
    end

    contents = File.read(version_path)
    updated = contents.sub(/VERSION = '[^']*'/, "VERSION = '#{version}'")
    File.write(version_path, updated)

    sh 'git', 'add', version_path
    sh 'git', 'commit', '-m', "Wheaties #{version}", '--', version_path
    sh 'git', 'tag', tag

    puts "Tagged #{tag}."
    branch = `git rev-parse --abbrev-ref HEAD`.strip
    print "Push #{branch} and #{tag} to origin? [y/N] "
    answer = $stdin.gets.to_s.strip.downcase
    if answer == 'y' || answer == 'yes'
      sh 'git', 'push', 'origin', branch, tag
    else
      puts "Skipped. Push later with: git push origin #{branch} #{tag}"
    end
  end

  desc 'Promote the bot running on staging to production on Northflank'
  task :promote do
    require 'json'
    require 'open3'

    deployed_sha = lambda do |service_id|
      output, status = Open3.capture2('northflank', 'get', 'service', '--projectId', 'wheaties',
        '--serviceId', service_id, '--output', 'json', '--quiet')
      abort "Couldn't read #{service_id} from Northflank. Is the Northflank CLI installed and logged in?" unless status.success?
      service = JSON.parse(output)
      service = service.first if service.is_a?(Array)
      service.dig('deployment', 'internal', 'deployedSHA')
    end

    staging_sha = deployed_sha.call('stg-bot')
    production_sha = deployed_sha.call('prd-bot')
    abort 'stg-bot has no deployed commit' unless staging_sha

    puts "Staging:    #{staging_sha[0, 7]}"
    puts "Production: #{production_sha ? production_sha[0, 7] : '(nothing deployed)'}"

    if staging_sha == production_sha
      abort 'Production already runs the same commit as staging.'
    end

    if production_sha
      sh 'git', 'fetch', '--quiet', 'origin'
      puts "\nCommits to promote:"
      system 'git', '--no-pager', 'log', '--oneline', "#{production_sha}..#{staging_sha}"
    end

    print "\nSnapshot prd-mongodb and promote #{staging_sha[0, 7]} to production? [y/N] "
    answer = $stdin.gets.to_s.strip.downcase
    abort 'Cancelled' unless answer == 'y' || answer == 'yes'

    sh 'northflank', 'run', 'workflow', '--projectId', 'wheaties', '--workflowId', 'promote-bot',
      '--input', '{}', '--quiet', out: File::NULL
    puts 'Started the promote-bot workflow. Follow it in Northflank under wheaties → production → Workflows.'
  end
end
