$:.unshift(File.join(__FILE__, "../lib"))

begin
  require "em-mongo"
  require "polyglot"
  require "treetop"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end

require "grunt/boot"
require "grunt/concerns/commands"
require "grunt/responses/messages"
require "grunt/handler"
