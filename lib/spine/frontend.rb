module Spine
  class Frontend
    include Utils

    def initialize tasks, opts = {}
      @tasks, @opts = tasks, opts
      @output = []
      @total_specs, @skipped_specs = 0, []
      @total_scenarios, @skipped_scenarios = 0, []
      @total_tests, @failed_tests, @failed_tests_amount = 0, {}, 0
    end

    def run
      @tasks.each_pair do |task_proc, task_setup|
        task_class = Class.new { include ::Spine::Task }
        task = task_class.new *task_setup, &task_proc
        @output.concat task.output
        @total_specs += task.spine__total_specs
        @total_scenarios += task.spine__total_scenarios
        @skipped_scenarios.concat task.spine__skipped_scenarios
        @total_tests += task.spine__total_tests
        @failed_tests.update task.spine__failed_tests
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

    def skipped_specs
      reset_stdout
      return stdout unless @skipped_specs.size > 0
      nl; stdout "--- Skipped Specs ---", 0, :a
      @skipped_specs.each { |tl| nl; stdout [' - ', tl].join, 0, :cyan }
      stdout
    end

    def skipped_scenarios
      reset_stdout
      return stdout unless @skipped_scenarios.size > 0
      nl; stdout "--- Skipped Scenarios ---", 0, :a
      @skipped_scenarios.each do |scenario|
        label, proc, spec, ident = scenario.values_at :label, :proc, :spec, :nesting_level
        nl
        stdout spec
        stdout label, ident
        stdout 'at %s' % proc_source(proc), ident, :w
      end
      stdout
    end

    def failed_tests
      reset_stdout
      return stdout unless @failed_tests.size > 0
      nl; stdout "--- Failed Tests ---", 0, :w
      backtrace_alert = nil
      nl
      @failed_tests.each_value do |tests|
        @failed_tests_amount += tests.size
        tests.each do |setup|

          task, spec, scenario, test, error, ident = setup

          stdout task
          stdout spec, 1
          stdout scenario, ident - 1
          stdout [a(test), error[:source]].join(' at '), ident

          if (exception = error[:exception]).is_a?(Exception)
            stdout exception.message, ident, :e
            if backtrace = exception.backtrace
              if @opts[:trace]
                backtrace.each { |s| stdout s, ident, :w }
              else
                backtrace_alert = true
              end
            end
          else
            message = error[:message] ? e(error[:message].to_s.strip) : '%s %s %s %s' % [
                w(error[:proxy]),
                error[:object],
                w(error[:method]),
                (error[:expected]||[]).compact.join(', ')
            ]
            stdout message, ident
          end
          if details = error[:details]
            details.each { |e| stdout e, ident, :e }
          end
        end
      end

      nl
      stdout 'use `:trace => true` to see error details' if backtrace_alert
      stdout
    end

    def summary
      reset_stdout
      nl; stdout '---'
      stdout 'Specs:       %s%s' % [@total_specs, @skipped_specs.size > 0 ? ' (%s skipped)' % @skipped_specs.size : '']
      stdout 'Scenarios:   %s%s' % [@total_scenarios, @skipped_scenarios.size > 0 ? ' (%s skipped)' % @skipped_scenarios.size : '']
      stdout 'Tests:       %s%s' % [
          @total_tests,
          @failed_tests_amount > 0 ? ' (%s failed)' % @failed_tests_amount : '',
      ], 0, @failed_tests_amount > 0 ? :red : :green
      stdout
    end

    def to_s
      (output + skipped_specs + skipped_scenarios + failed_tests + summary).join("\n")
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
      (@stdout||reset_stdout) << (color ? self.send(color, str) : str)
    end

  end
end
