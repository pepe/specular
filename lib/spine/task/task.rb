module Spine
  class Task

    include Utils

    def initialize label = nil, &proc

      proc || raise('--- tasks need a proc to run ---')

      vars = {
          instance_variables: {}, nesting_level: 0, context: [],
          output: [], source_files: {},
          current_task: {label: label, proc: proc},
          current_spec: nil, total_specs: 0,
          current_scenario: nil, total_scenarios: 0, skipped_scenarios: [], failed_scenarios: [],
          test: nil, total_tests: 0, failed_tests: {},
          hooks: {a: {}, z: {}}, browser: nil,
      }
      @__spine__vars_pool__ = Struct.new(*vars.keys).new(*vars.values)

      nl; output label.to_s
      spine__nesting_level :+

      self.instance_exec &proc
    end

    def helper mdl
      self.class.class_exec { include mdl }
    end

    def spine__context
      @__spine__vars_pool__.context
    end

    def spine__current_task
      @__spine__vars_pool__.current_task
    end

    def spine__source_files
      @__spine__vars_pool__.source_files
    end

    def spine__nesting_level op = nil
      @__spine__vars_pool__.nesting_level += 1 if op == :+
      @__spine__vars_pool__.nesting_level -= 1 if op == :-
      @__spine__vars_pool__.nesting_level
    end

    def output output = nil, color = nil
      @__spine__vars_pool__.output << [output, spine__nesting_level, color] if output
      @__spine__vars_pool__.output
    end

    def nl
      output ''
    end

    def ivar_set var, val
      @__spine__vars_pool__.instance_variables[var] = val
    end

    def ivar_get var
      @__spine__vars_pool__.instance_variables[var]
    end

  end
end
