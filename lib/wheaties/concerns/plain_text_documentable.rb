module Wheaties
  module PlainTextDocumentable
    USAGE = '[options]'
    HELP = <<~EOS
      Options:
      -c / --count <number>: Return this many lines.
      -f / --find <text|regexp>: Only return lines containing <text> (case-insensitive) or matching the /regexp/.
      -g / --grep <text|regexp>: Alias for `--find`.
      -s / --sort <ascending|asc|descending|desc|random|rand>: Sort lines in this order.
    EOS

    def help
      HELP
    end

    def usage
      "#{name} #{USAGE}"
    end
  end
end
