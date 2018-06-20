module Wheaties
  module FormattingHelpers
    # Constants
    COLORS = %i(aqua black blue brown green grey lime orange pink purple red royal silver teal white
      yellow)

    private

    def bold(text = '')
      Cinch::Formatting.format(:bold, text)
    end
    alias_method :b, :bold

    def color(foreground, background = nil, text = '')
      Cinch::Formatting.format(foreground, background, text)
    end
    alias_method :co, :color

    def italic(text = '')
      Cinch::Formatting.format(:italic, text)
    end
    alias_method :i, :italic

    def unformat(text = '')
      Cinch::Formatting.unformat(text)
    end
    alias_method :plain, :unformat
    alias_method :pl, :unformat
    alias_method :uncolor, :unformat
    alias_method :uc, :unformat

    COLORS.each do |color_name|
      define_method(color_name) do |text|
        color(color_name, nil, text)
      end
    end
  end
end
