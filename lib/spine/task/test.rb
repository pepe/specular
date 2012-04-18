module Spine
  module Task

    [:Test, :Testing,
     :Given, :When, :Then,
     :It, :He, :She,
     :If, :Let, :Say, :Assume, :Suppose,
     :And, :Or, :Nor, :But, :However, :Should].each do |prefix|
      define_method prefix do |*args, &proc|
        spine__test prefix, *args, &proc
      end
    end

    def spine__test prefix, goal, opts = {}, &proc

      proc || raise('--- tests need a proc to run ---')

      name = [prefix, goal].join(' ')

      spine__total_tests :+
      spine__nesting_level :+

      prev_test = spine__current_test
      spine__current_test name: name,
                          proc: proc,
                          task: (spine__current_task||{})[:name],
                          spec: (spine__current_spec||{})[:name],
                          ident: spine__nesting_level

      spine__context << proc

      spine__test_skipped if opts[:skip]
      spine__output(name) unless spine__context_skipped?

      # executing :before hooks
      spine__hooks(:a).each { |hook| self.instance_exec(goal, opts, &hook) }

      self.instance_exec &proc

      # executing :after hooks
      spine__hooks(:z).each { |hook| self.instance_exec(goal, opts, &hook) }

      spine__context.pop
      spine__nesting_level :-

      spine__current_test prev_test

      spine__output('') unless spine__context_skipped?
    end

    def spine__current_test *args
      @__spine__vars_pool__.current_test = args.first if args.size > 0
      @__spine__vars_pool__.current_test
    end

    def spine__total_tests op = nil
      @__spine__vars_pool__.total_tests += 1 if op == :+
      @__spine__vars_pool__.total_tests
    end

    def spine__skipped_tests
      @__spine__vars_pool__.skipped_tests
    end

    def spine__test_skipped
      spine__skipped_tests[spine__context.dup] = spine__current_test
    end

    def spine__test_skipped?
      spine__skipped_tests.each_key do |context|
        return true if spine__context[0, context.size] == context
      end
      nil
    end

  end
end
