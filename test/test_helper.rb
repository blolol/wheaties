begin
  require "test/unit"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end
