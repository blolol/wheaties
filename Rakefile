require 'shellwords'

def wheaties_version_tag
  require_relative './lib/wheaties/version'
  "blolol/wheaties:#{Wheaties::VERSION}"
end

def northflank_json(*args)
  require 'json'
  require 'open3'
  output, status = Open3.capture2('northflank', *args, '--projectId', 'wheaties', '--output', 'json', '--quiet')
  abort "Couldn't run `northflank #{args.join(' ')}`. Is the Northflank CLI installed and logged in?" unless status.success?
  JSON.parse(output)
end

def git_ancestor?(ancestor, descendant)
  system('git', 'merge-base', '--is-ancestor', ancestor, descendant, err: File::NULL)
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

  desc 'Wait until a commit (default HEAD) is built and deployed to staging on Northflank'
  task :wait, %i(ref) do |task, args|
    ref = args[:ref] || 'HEAD'
    sha = `git rev-parse --verify -q #{"#{ref}^{commit}".shellescape}`.strip
    abort "Unknown commit: #{ref}" if sha.empty?
    short_sha = sha[0, 7]

    sh 'git', 'fetch', '--quiet', 'origin'
    unless git_ancestor?(sha, 'origin/main')
      abort "#{short_sha} isn't on origin/main, so staging won't deploy it. Push it first."
    end

    timeout = ENV.fetch('TIMEOUT', 20 * 60).to_i
    deadline = Time.now + timeout
    puts "Waiting for #{short_sha} to deploy to stg-bot..."
    last_state = nil

    loop do
      active = northflank_json('list', 'service', 'deployments', '--serviceId', 'stg-bot')['deployments']
        .find { |deployment| deployment['active'] }
      active_sha = active&.dig('commit', 'sha')
      service = northflank_json('get', 'service', '--serviceId', 'stg-bot')
      service = service.first if service.is_a?(Array)
      rollout = service.dig('status', 'deployment', 'status')

      # A later commit that includes this one also counts, in case main moved on while we waited.
      if active_sha && rollout == 'COMPLETED' && (active_sha == sha || git_ancestor?(sha, active_sha))
        puts "stg-bot is running #{active_sha[0, 7]}, which includes #{short_sha}."
        break
      end

      build = northflank_json('get', 'service', 'builds', '--serviceId', 'build-bot')['builds']
        .find { |candidate| candidate['sha'] == sha }
      if build && build['concluded'] && build['status'] != 'SUCCESS'
        abort "build-bot build #{build['id']} of #{short_sha} finished with #{build['status']}."
      end
      abort "stg-bot's rollout failed while deploying #{short_sha}." if build&.dig('status') == 'SUCCESS' && rollout == 'FAILED'

      build_state = build ? "build #{build['id']} #{build['status']}" : 'build not started'
      state = "#{build_state}; stg-bot #{active_sha ? active_sha[0, 7] : '(none)'} #{rollout}"
      puts "#{Time.now.strftime('%T')} #{state}" unless state == last_state
      last_state = state

      abort "Timed out after #{timeout}s waiting for #{short_sha} (#{state})." if Time.now > deadline
      sleep 10
    end
  end

  desc 'Promote the bot running on staging to production on Northflank'
  task :promote do
    require 'time'

    northflank_service = lambda do |service_id|
      service = northflank_json('get', 'service', '--serviceId', service_id)
      service.is_a?(Array) ? service.first : service
    end
    deployed_sha = ->(service_id) { northflank_service.call(service_id).dig('deployment', 'internal', 'deployedSHA') }
    workflow_run_ids = lambda do
      northflank_json('list', 'workflow-runs', '--workflowId', 'promote-bot')['runs'].map { |run| run['id'] }
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

    # The run endpoint doesn't document its response, so find the new run by diffing the run list.
    previous_run_ids = workflow_run_ids.call
    sh 'northflank', 'run', 'workflow', '--projectId', 'wheaties', '--workflowId', 'promote-bot',
      '--input', '{}', '--quiet', out: File::NULL

    short_sha = staging_sha[0, 7]
    timeout = ENV.fetch('TIMEOUT', 20 * 60).to_i
    deadline = Time.now + timeout
    puts "Started the promote-bot workflow. Waiting for #{short_sha} to deploy to prd-bot..."
    run_id = nil
    last_state = nil

    loop do
      run_id ||= workflow_run_ids.call.find { |id| !previous_run_ids.include?(id) }
      run = run_id && northflank_json('get', 'workflow-run', '--workflowId', 'promote-bot', '--runId', run_id)

      if run&.dig('concluded')
        abort "promote-bot run #{run_id} finished with #{run['status']}." unless run['status'] == 'success'

        # The workflow concludes once the Release step starts prd-bot's rollout, so wait for the
        # rollout too. Its transition time rules out the previous deploy's COMPLETED status.
        service = northflank_service.call('prd-bot')
        production_sha = service.dig('deployment', 'internal', 'deployedSHA')
        rollout = service.dig('status', 'deployment')
        rolled_out_since_run = rollout && Time.iso8601(rollout['lastTransitionTime']) > Time.iso8601(run['startedAt'])

        if production_sha == staging_sha && rolled_out_since_run
          if rollout['status'] == 'COMPLETED'
            puts "prd-bot is running #{short_sha}."
            break
          end
          abort "prd-bot's rollout failed while deploying #{short_sha}." if rollout['status'] == 'FAILED'
        end

        state = "workflow #{run['status']}; prd-bot #{production_sha ? production_sha[0, 7] : '(none)'} #{rollout&.dig('status')}"
      elsif run
        steps = run.dig('spec', 'spec', 'steps').to_a.map { |step| "#{step['kind']} #{step.dig('response', 'status') || 'pending'}" }
        state = "workflow #{run['status']} (#{steps.join(', ')})"
      else
        state = 'workflow run not found yet'
      end

      puts "#{Time.now.strftime('%T')} #{state}" unless state == last_state
      last_state = state

      abort "Timed out after #{timeout}s waiting for #{short_sha} (#{state})." if Time.now > deadline
      sleep 10
    end
  end
end
