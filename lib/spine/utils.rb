module Spine
  module Utils

    def proc_source proc
      proc.source_location.join(':')
    end

    module Colors
      def red str, ec = 0
        colorize(str, "\e[#{ ec }m\e[31m");
      end

      alias e red

      def green str, ec = 0
        colorize(str, "\e[#{ ec }m\e[32m");
      end

      alias s green

      def yellow str, ec = 0
        colorize(str, "\e[#{ ec }m\e[33m");
      end

      def blue str, ec = 0
        colorize(str, "\e[#{ ec }m\e[34m");
      end

      alias a blue

      def magenta str, ec = 0
        colorize(str, "\e[#{ ec }m\e[35m");
      end

      alias w magenta

      def cyan str, ec = 0
        colorize(str, "\e[#{ ec }m\e[36m");
      end

      def white str, ec = 0
        colorize(str, "\e[#{ ec }m\e[37m");
      end

      def colorize(text, color_code)
        "#{color_code}#{text}\e[0m"
      end
    end
    class << self
      include Colors
    end
    include Colors
  end
end
