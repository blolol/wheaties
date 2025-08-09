module Wheaties
  class PlainTextInvocationResult
    def initialize(text, args, options = {})
      @text = text
      @args = args
      @options = parse_options(options)
      @lines = select_lines
    end

    def reply_to_chat(message)
      each_line do |line|
        message.safe_reply(line)
      end
    end

    def ruby_value
      @lines
    end

    private

    def each_line(&block)
      @lines.each(&block)
    end

    def grep(lines)
      return lines unless @options[:grep].present?
      pattern = @args.unstringify(@options[:grep])

      unless pattern.is_a?(Regexp)
        # Build a case-insensitive regexp that matches the given string anywhere in the line
        pattern = /.*#{Regexp.escape(pattern)}.*/i
      end

      lines.grep(pattern)
    end

    def limit(lines)
      return lines unless @options[:count].present? && @options[:count] > 0
      lines.first(@options[:count])
    end

    def parse_options(options)
      @args.parse_options(into: options) do |parser|
        parser.on('-c', '--count [COUNT]', Integer)
        parser.on('-f', '--find [PATTERN]')
        parser.on('-g', '--grep [PATTERN]')
        parser.on('-s', '--sort [ORDER]', String)
      end

      options[:grep] ||= options.delete(:find)

      options
    end

    def select_lines
      lines = @text.lines
      lines = grep(lines)
      lines = sort(lines)
      lines = limit(lines)
      lines
    end

    def sort(lines)
      return lines unless @options[:sort].present?

      case @options[:sort].to_s.downcase
      when 'ascending', 'asc' then lines.sort
      when 'descending', 'desc' then lines.sort.reverse
      when 'random', 'rand' then lines.shuffle
      else lines
      end
    end
  end
end
