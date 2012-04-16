module Spine
  module Task

    [:Given, :When, :Then, :It, :If, :Let, :Say, :Assume, :Suppose, :And, :Nor, :But, :However, :Should].each do |prefix|
      define_method prefix do |*args, &proc|
        spine__scenario prefix, *args, &proc
      end
    end

    def spine__scenario prefix, goal, opts = {}, &proc

      proc || raise('--- scenarios need a proc to run ---')

      name = [prefix, goal].join(' ')

      spine__total_scenarios :+
      spine__nesting_level :+

      prev_scenario = spine__current_scenario
      spine__current_scenario name: name,
                              proc: proc,
                              task: (spine__current_task||{})[:name],
                              spec: (spine__current_spec||{})[:name],
                              ident: spine__nesting_level

      spine__context << proc

      spine__scenario_skipped if opts[:skip]
      spine__output(name) unless spine__context_skipped?

      self.instance_exec &proc

      spine__context.pop
      spine__nesting_level :-

      spine__current_scenario prev_scenario

      spine__output('') unless spine__context_skipped?
    end

    def spine__current_scenario *args
      @__spine__vars_pool__.current_scenario = args.first if args.size > 0
      @__spine__vars_pool__.current_scenario
    end

    def spine__total_scenarios op = nil
      @__spine__vars_pool__.total_scenarios += 1 if op == :+
      @__spine__vars_pool__.total_scenarios
    end

    def spine__skipped_scenarios
      @__spine__vars_pool__.skipped_scenarios
    end

    def spine__scenario_skipped
      spine__skipped_scenarios[spine__context.dup] = spine__current_scenario
    end

    def spine__scenario_skipped?
      spine__skipped_scenarios.each_key do |context|
        return true if spine__context[0, context.size] == context
      end
      nil
    end

  end
end
