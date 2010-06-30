module Grunt
  class Setting
    class << self
      def get(name, default = nil)
        if setting = Command.first(:name => /^#{Regexp.escape(name)}$/i, :type => "plain_text")
          unserialize(setting.body)
        else
          default
        end
      end
      
      def set(name, value)
        setting = Command.first_or_new(:name => name, :type => "plain_text")
        setting.body = serialize(value)
        setting.save
      end
      
      def unserialize(value)
        if value.strip[0..2] == "---"
          begin
            YAML.load(value) || {}
          rescue; nil; end
        else
          value.to_s
        end
      end
      
      def serialize(value)
        case value
        when Hash, Array, Fixnum, Float
          begin
            YAML.dump(value)
          rescue; "---"; end
        else
          value.to_s
        end
      end
    end # class << self
  end # Setting
end
