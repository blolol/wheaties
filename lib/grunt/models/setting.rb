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
      
      def increment(name, by = 1)
        by = case by
             when Numeric then by
             when String then by.to_num
             else
               raise ArgumentError, "cannot increment by the value of a #{by.class.name}"
             end
        
        setting = get(name) || 0
        setting = case setting
                  when Numeric then setting
                  when String then setting.to_num
                  else
                    raise ArgumentError, "#{setting.class.name} cannot be incremented"
                  end
        
        setting += by
        set(name, setting)
        setting
      end
      alias :inc :increment
      
      def decrement(name, by = 1)
        increment(name, by * -1)
      end
      alias :dec :decrement
      
      protected
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
          when Hash, Array, Numeric
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
