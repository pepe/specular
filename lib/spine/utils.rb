module Spine
  module Utils

    def proc_source proc
      proc.source_location.join(':')
    end

    module Colorize
      class << self
        def info str
          str
        end

        def error str, ec = 0
          colorize(str, "\e[#{ ec }m\e[31m");
        end

        def success str, ec = 0
          colorize(str, "\e[#{ ec }m\e[32m");
        end

        def alert str, ec = 0
          colorize(str, "\e[#{ ec }m\e[34m");
        end

        def warn str, ec = 0
          colorize(str, "\e[#{ ec }m\e[35m");
        end

        def colorize(text, color_code)
          "#{color_code}#{text}\e[0m"
        end
      end
    end

  end
end
