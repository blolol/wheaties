$:.unshift(File.join(__FILE__, "..", "lib"))

begin
  require "mongo_mapper"
  require "polyglot"
  require "treetop"
  require "system_timer"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

require "grunt/boot"
require "grunt/command_node_classes"
require "grunt/errors"
require "grunt/evaluator"
require "grunt/models/command"
require "grunt/responses/messages"
require "grunt/handler"
