module Spine
  module Task

    include Utils

    def initialize label = nil, &proc

      proc || raise('--- tasks need a proc to run ---')

      output, host = [], self
      [:info, :success, :warn, :alert, :error].each do |meth|
        output.define_singleton_method meth do |snippet|
          self << [snippet.to_s, host.spine__nesting_level, __method__]
        end
      end
      output.define_singleton_method :debug do |snippet|
        self << [snippet.to_s, host.spine__nesting_level]
        if host.failed?
          (host.spine__failed_tests[host.spine__context.dup].last[4][:details]||=[]) << snippet.to_s
        end
      end
      output.define_singleton_method :br do
        self << ['']
      end

      vars = {
          nesting_level: 0, context: [],
          output: output, source_files: {},
          current_task: {label: label, proc: proc},
          current_spec: nil, total_specs: 0,
          current_scenario: nil, total_scenarios: 0, skipped_scenarios: [], failed_scenarios: [],
          test: nil, test_passed: nil, total_tests: 0, failed_tests: {},
          hooks: {a: {}, z: {}}, browser: nil,
      }
      @__spine__vars_pool__ = Struct.new(*vars.keys).new(*vars.values)

      spine__output.br
      spine__output label
      spine__nesting_level :+

      self.instance_exec &proc
    end

    def helper mdl
      self.class.class_exec { include mdl }
    end

    def spine__output s = nil
      return @__spine__vars_pool__.output.info(s) if s
      @__spine__vars_pool__.output
    end

    alias o spine__output
    alias d spine__output

    def spine__context
      @__spine__vars_pool__.context
    end

    def spine__current_task
      @__spine__vars_pool__.current_task
    end

    def spine__source_files
      @__spine__vars_pool__.source_files
    end

    def spine__failures?
      spine__failed_tests.each_key do |context|
        return true if spine__context[0, context.size] == context
      end
      nil
    end

    def spine__nesting_level op = nil
      @__spine__vars_pool__.nesting_level += 1 if op == :+
      @__spine__vars_pool__.nesting_level -= 1 if op == :-
      @__spine__vars_pool__.nesting_level
    end

  end
end
