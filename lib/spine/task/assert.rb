module Spine
  module Task

    [:is, :is?, :are, :are?, :does, :does?, :expect, :assert, :check].each do |meth|
      define_method meth do |*args, &proc|
        ::Spine::Assert.new(true, self, __method__, args.first, &proc)
      end
    end

    [:refute, :false?].each do |meth|
      define_method meth do |*args, &proc|
        ::Spine::Assert.new(false, self, __method__, args.first, &proc)
      end
    end

    def passed? *args
      @__spine__vars_pool__.assertion_passed = args.first if args.size > 0
      @__spine__vars_pool__.assertion_passed
    end

    def failed?
      !passed?
    end

    def spine__total_assertions op = nil
      @__spine__vars_pool__.total_assertions += 1 if op == :+
      @__spine__vars_pool__.total_assertions
    end

    def spine__failed_assertions assertion = nil, error = nil
      @__spine__vars_pool__.failed_assertions[spine__context.dup] = [
          (spine__current_task || {})[:name],
          (spine__current_spec || {})[:name],
          (spine__current_test || {})[:name],
          assertion,
          error,
          spine__nesting_level
      ] if assertion
      @__spine__vars_pool__.failed_assertions
    end

  end
end
