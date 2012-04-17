module Spine
  class Frontend

    include Utils

    def initialize tasks, opts = {}
      @tasks, @opts = tasks, opts
      @output = []
      @skipped_tasks = {}
      @total_specs, @skipped_specs = 0, {}
      @total_scenarios, @skipped_scenarios = 0, {}
      @total_tests, @failed_tests, @failed_tests_amount = 0, {}, 0
    end

    def run
      @tasks.each do |task|

        task_args, task_proc = task
        task_class = Class.new { include ::Spine::Task }
        task_instance = task_class.new *task_args, &task_proc

        @output.concat task_instance.spine__output

        @skipped_tasks.update task_instance.spine__skipped_tasks

        @total_specs += task_instance.spine__total_specs
        @skipped_specs.update task_instance.spine__skipped_specs

        @total_scenarios += task_instance.spine__total_scenarios
        @skipped_scenarios.update task_instance.spine__skipped_scenarios

        @total_tests += task_instance.spine__total_tests
        @failed_tests.update task_instance.spine__failed_tests
      end
      self
    end

    def passed?
      @failed_tests_amount == 0
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
      @skipped_tasks.each_value do |t|
        nl
        stdout '%s at %s' % [t[:name], proc_source(t[:proc])]
      end
      stdout
    end

    def skipped_specs
      reset_stdout
      return stdout unless @skipped_specs.size > 0
      nl; stdout "--- Skipped Specs ---", 0, :alert
      @skipped_specs.each_value do |s|
        nl
        stdout s[:task]
        stdout '%s at %s' % [s[:name], proc_source(s[:proc])], 1
      end
      stdout
    end

    def skipped_scenarios
      reset_stdout
      return stdout unless @skipped_scenarios.size > 0
      nl; stdout "--- Skipped Scenarios ---", 0, :alert
      @skipped_scenarios.each_value do |s|
        nl
        stdout s[:task]
        stdout s[:spec], 1
        stdout '%s at %s' % [s[:name], proc_source(s[:proc])], s[:ident] - 1
      end
      stdout
    end

    def failed_tests
      reset_stdout
      return stdout unless @failed_tests.size > 0
      nl; stdout "--- Failed Tests ---", 0, :warn
      backtrace_alert = nil
      nl
      @failed_tests.each_value do |setup|
        @failed_tests_amount += 1

        task, spec, scenario, test, error, ident = setup

        nl
        stdout task
        stdout spec, 1
        stdout scenario, ident
        stdout [Colorize.alert(test), error[:source]].join(' at '), ident

        if (exception = error[:exception]).is_a?(Exception)
          stdout exception.message, ident, :error
          if backtrace = exception.backtrace
            if @opts[:trace]
              backtrace.each { |s| stdout s, ident, :w }
            else
              backtrace_alert = true
            end
          end
        else
          message = error[:message] ?
              Colorize.error(error[:message].to_s.strip) :
              '%s %s %s %s' % [
                  Colorize.warn(error[:proxy]),
                  error[:object],
                  Colorize.warn(error[:method]),
                  (error[:expected]||[]).compact.join(', ')
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
      stdout 'Specs:       %s%s' % [@total_specs, @skipped_specs.size > 0 ? ' (%s skipped)' % @skipped_specs.size : '']
      stdout 'Scenarios:   %s%s' % [@total_scenarios, @skipped_scenarios.size > 0 ? ' (%s skipped)' % @skipped_scenarios.size : '']
      stdout 'Tests:       %s%s' % [
          @total_tests,
          @failed_tests_amount > 0 ? ' (%s failed)' % @failed_tests_amount : '',
      ], 0, @failed_tests_amount > 0 ? :error : :success
      stdout
    end

    def to_s
      (output + skipped_tasks + skipped_specs + skipped_scenarios + failed_tests + summary).join("\n")
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
      str = [' '*(2*ident), chunk].join
      (@stdout||reset_stdout) << (color ? Colorize.send(color, str) : str)
    end

  end
end
