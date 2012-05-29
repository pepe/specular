module Enter
  class Frontend

    include Utils

    def initialize tasks, opts = {}
      @tasks, @opts = tasks, opts
      @output = []
      @skipped_tasks = []
      @total_tests, @skipped_tests = 0, []
      @total_assertions, @failed_assertions = 0, {}
    end

    def run
      @tasks.each do |task|

        task_args, task_proc = task
        task_class = Class.new { include ::Enter::Task }
        task_instance = task_class.new *task_args, &task_proc

        @output.concat task_instance.__enter__output__

        @skipped_tasks += task_instance.__enter__skipped_tasks__

        @total_tests += task_instance.__enter__total_tests__
        @skipped_tests += task_instance.__enter__skipped_tests__

        @total_assertions += task_instance.__enter__total_assertions__
        @failed_assertions.update task_instance.__enter__failed_assertions__
      end
      self
    end

    def passed?
      failed == 0
    end

    def failed?
      failed > 0
    end

    def exit_code
      passed? ? 0 : 1
    end

    def failed
      @failed_assertions.size
    end

    def output
      reset_stdout
      @output.each { |setup| stdout *setup }
      stdout
    end

    def skipped_tasks
      reset_stdout
      return stdout unless @skipped_tasks.size > 0
      nl; stdout "--- Skipped Tasks ---", 0, :alert
      @skipped_tasks.each do |t|
        nl
        stdout '%s at %s' % [t[:name], proc_source(t[:proc])]
      end
      stdout
    end

    def skipped_tests
      reset_stdout
      return stdout unless @skipped_tests.size > 0
      nl; stdout "--- Skipped Tests ---", 0, :alert
      @skipped_tests.each do |t|
        nl
        stdout t[:task]
        stdout '%s at %s' % [t[:name], proc_source(t[:proc])], t[:ident] - 1
      end
      stdout
    end

    def failures
      reset_stdout
      return stdout unless @failed_assertions.size > 0
      nl; stdout "--- Failed Tests ---", 0, :warn
      backtrace_alert = nil
      nl
      @failed_assertions.each_value do |setup|

        task, test, assertion, error, ident = setup

        nl
        stdout task
        stdout test, ident
        stdout [Colorize.alert(assertion), error[:source]].join(' at '), ident

        if (exception = error[:exception]).is_a?(Exception)
          stdout exception.message, ident, :error
          if backtrace = exception.backtrace
            if @opts[:trace]
              backtrace.each { |s| stdout s, ident }
            else
              backtrace_alert = true
            end
          end
        else
          message = error[:message] ?
              Colorize.error(error[:message].to_s.strip) :
              '%s %s %s %s' % [
                  Colorize.warn(error[:proxy]),
                  presenter__expected_vs_received(error[:object]),
                  Colorize.warn(error[:method]),
                  presenter__expected_vs_received(*error[:expected])
              ]
          stdout message, ident
        end
        if details = error[:details]
          details.each { |e| stdout e[0], ident, e[1] }
        end

      end

      nl
      stdout 'use `:trace => true` to see error details' if backtrace_alert
      stdout
    end

    def summary
      reset_stdout
      nl; stdout '---'
      stdout 'Tasks:       %s%s' % [@tasks.size, @skipped_tasks.size > 0 ? ' (%s skipped)' % @skipped_tasks.size : '']
      stdout 'Tests:       %s%s' % [@total_tests, @skipped_tests.size > 0 ? ' (%s skipped)' % @skipped_tests.size : '']
      stdout 'Assertions:  %s%s' % [@total_assertions, passed? ? '' : ' (%s failed)' % failed], 0, passed? ? :success : :error
      stdout
    end

    def to_s
      (output + skipped_tasks + skipped_tests + failures + summary).join("\n")
    end

    private
    def nl
      stdout ''
    end

    def reset_stdout
      @stdout = []
    end

    def stdout chunk = nil, ident = 0, color = nil
      unless chunk
        output = (@stdout||reset_stdout)

        def output.to_s
          self.join("\n")
        end

        return output
      end
      str = [' '*(2* (ident > 0 ? ident : 0)), chunk].join
      (@stdout||reset_stdout) << (color ? Colorize.send(color, str) : str)
    end

    def presenter__expected_vs_received *objects
      objects.map do |obj|
        [NilClass, String, Symbol].include?(obj.class) ? obj.inspect : obj
      end.join(', ')
    end

  end
end
