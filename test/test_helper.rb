begin
  require "test/unit"
  require "shoulda"
  require "matchy"
rescue LoadError => e
  if require "rubygems"
    retry
  else
    raise e
  end
end
