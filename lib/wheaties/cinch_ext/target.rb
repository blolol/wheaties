module Cinch
  class Target
    def self.return_nil_from(*method_names)
      method_names.each do |method_name|
        with_return_nil_method = :"#{method_name}_with_nil_return"
        without_return_nil_method = :"#{method_name}_without_nil_return"

        define_method(with_return_nil_method) do |*args|
          __send__(without_return_nil_method, *args)
          nil
        end
        alias_method without_return_nil_method, method_name
        alias_method method_name, with_return_nil_method
      end
    end

    # Patch until this commit is released:
    # https://github.com/cinchrb/cinch/commit/4d2919032d6ac6b3d1cd011c4ace059aa77e8739
    def safe_action(text)
      action(Cinch::Helpers.sanitize(text))
    end

    return_nil_from :action, :ctcp, :notice, :send
  end
end
