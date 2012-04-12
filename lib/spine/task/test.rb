module Spine
  class Task

    [:is, :is?, :are, :are?, :does, :does?, :expect, :assert].each do |meth|
      define_method meth do |object = nil, &proc|
        Evaluator.new true, self, __method__, object, &proc
      end
    end

    [:refute, :false?].each do |meth|
      define_method meth do |object = nil, &proc|
        Evaluator.new false, self, __method__, object, &proc
      end
    end

    def passed? *args
      ivar_set :passed, args.first if args.size > 0
      ivar_get :passed
    end

    def failed?
      !passed?
    end

    def error error
      (failed_tests.last[3][:details]||=[]) << error
    end

    def spine__total_tests op = nil
      @__spine__vars_pool__.total_tests += 1 if op == :+
      @__spine__vars_pool__.total_tests
    end

    def spine__failed_tests test = nil, error = nil
      (@__spine__vars_pool__.failed_tests[spine__context.dup] ||= []) << [
          (spine__current_task || {})[:label],
          (spine__current_spec || {})[:label],
          (spine__current_scenario || {})[:label],
          test,
          error,
          spine__nesting_level
      ] if test
      @__spine__vars_pool__.failed_tests
    end

  end
end
