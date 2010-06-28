$:.unshift(File.join(__FILE__, "..", "lib"))

require "digest/sha1"

begin
  require "active_support"
  require "mongo_mapper"
  require "polyglot"
  require "treetop"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

begin
  require "system_timer"
  GruntTimeout = SystemTimer
rescue LoadError
  require "timeout"
  GruntTimeout = Timeout
end

require "grunt/extensions/array"
require "grunt/extensions/channel"
require "grunt/extensions/set"

require "grunt/concerns/commands"
require "grunt/concerns/convenience"

require "grunt/boot"
require "grunt/arguments.rb"
require "grunt/errors"
require "grunt/evaluator"
require "grunt/models/command"
require "grunt/responses/messages"
require "grunt/handler"
require "grunt/range"
