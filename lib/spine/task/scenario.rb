module Spine
  class Task

    [:Given, :When, :Then, :It, :If, :Let, :Say, :Assume, :Suppose, :And, :But, :Should].each do |prefix|
      define_method prefix do |*args, &proc|
        spine__scenario prefix, *args, &proc
      end
    end

    def spine__scenario prefix, goal, opts = {}, &proc

      proc || raise('--- scenarios need a proc to run ---')

      label = [prefix, goal].join(' ')
      output label

      spine__total_scenarios :+

      spine__scenario_skipped if opts[:skip]

      if spine__scenario_skipped?
        return output(' - scenario skipped explicitly', :w)
      elsif spine__scenario_failed?
        return output(' - scenario skipped due to previous failures', :w)
      end

      prev_scenario = spine__current_scenario
      spine__current_scenario label: label, proc: proc

      spine__nesting_level :+
      spine__context << proc

      self.instance_exec &proc

      spine__context.pop
      spine__nesting_level :-

      spine__current_scenario prev_scenario
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
      @__spine__vars_pool__.skipped_scenarios << spine__current_scenario
    end

    def spine__scenario_skipped?
      @__spine__vars_pool__.skipped_scenarios.include? spine__current_scenario
    end

    def spine__scenario_failed
      @__spine__vars_pool__.failed_scenarios << spine__context.dup
    end

    def spine__scenario_failed?
      @__spine__vars_pool__.failed_scenarios.each do |context|
        return true if spine__context[0, context.size] == context
      end
      nil
    end

  end
end
