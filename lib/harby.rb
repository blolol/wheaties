require 'harby/concerns/delegation'
require 'harby/ext/compiled_parser'
require 'harby/ext/syntax_node'

%w(command list numeric regex string arguments).each do |name|
  Treetop.load File.join(File.dirname(__FILE__), "harby/grammar/#{name}")
end

require 'harby/parser'
