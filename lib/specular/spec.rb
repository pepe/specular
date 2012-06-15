class Specular
  module Spec

    SPEC_ALIASES = [:Should, :Describe, :Context,
                    :Test, :Testing, :Set, :Setting,
                    :Given, :When, :Then,
                    :It, :He, :She,
                    :If, :Let, :Say, :Assume, :Suppose,
                    :And, :Or, :Nor, :But, :However]

    ASSERT_ALIASES = [:is, :is?,
                      :are, :are?,
                      :does, :does?,
                      :expect, :assert, :check]
    NEGATIVE_ASSERT_ALIASES = [:refute, :false?]

    module SpecularBaseMixin

      def initialize

        vars = {
            :nesting_level => 0, :context => [],
            :output => OutputProxy.new(self), :source_files => {},
            :current_spec => nil, :skipped_specs => [],
            :current_test => nil, :total_tests => 0, :skipped_tests => [],
            :total_assertions => 0, :failed_assertions => {},
            :hooks => {:a => [], :z => []}, :browser => nil
        }
        @__specular__vars_pool__ = Struct.new(*vars.keys).new(*vars.values)

      end

      def __specular__run__ *args, &proc

        proc || raise('--- specs need a proc to run ---')

        opts = args.last.is_a?(Hash) ? args.pop : {}
        name = args.first

        __specular__.current_spec = {:name => name, :proc => proc}

        if (skip = opts[:skip]) && (skip.is_a?(Proc) ? skip.call : true)
          return __specular__skipped_specs__ << __specular__current_spec__
        end

        __specular__output__ ''
        __specular__output__ __specular__current_spec__[:name]

        catch __specular__fail_symbol__ do
          self.instance_exec *args, &proc
        end
      end

      def __specular__output__ snippet = nil, color = nil
        __specular__.output << [snippet.to_s, __specular__nesting_level__, color].compact if snippet
        __specular__.output
      end

      def __specular__context__
        __specular__.context
      end

      def __specular__current_spec__
        __specular__.current_spec
      end

      def __specular__skipped_specs__
        __specular__.skipped_specs
      end

      def __specular__source_files__
        __specular__.source_files
      end

      def __specular__last_error__
        (__specular__failed_assertions__.values.last || [])[4] || {}
      end

      def __specular__fail_symbol__
        ('__specular__fail_symbol__%s__' % __specular__context__.dup.last).to_sym
      end

      def __specular__hooks__ position
        __specular__.hooks[position].map do |map|
          context, hook = map
          hook if __specular__context__[0, context.size] == context
        end.compact
      end

      def __specular__nesting_level__ op = nil
        __specular__.nesting_level += 1 if op == :+
        __specular__.nesting_level -= 1 if op == :-
        __specular__.nesting_level
      end

      private
      def __specular__
        @__specular__vars_pool__
      end

    end
    include SpecularBaseMixin

    module SpecularFrontendMixin

      def include mdl
        self.class.class_exec { include mdl }
      end

      def o s = nil
        return __specular__.output.info(s) if s
        __specular__.output
      end

      alias d o

      # blocks to be executed before/after each test.
      #
      # please note that in case of nested tests,
      # children will override variables set by parents.
      # @example
      #    Spec.new do
      #
      #      before do
      #        @n = 0
      #      end
      #
      #      Test :Nr1 do
      #
      #        # @n is 0
      #        @n += 1 # @n is 1
      #
      #        Test :Nr1_1 do
      #          # @n is 0
      #        end
      #
      #        # @n is 0 cause it was override by Test Nr1_1 when it called `before` hook
      #      end
      #
      #    end
      #
      def before &proc
        __specular__.hooks[:a] << [__specular__context__.dup, proc]
      end

      def after &proc
        __specular__.hooks[:z] << [__specular__context__.dup, proc]
      end

    end
    include SpecularFrontendMixin

    module SpecularAssertMixin

      ASSERT_ALIASES.each do |meth|
        define_method meth do |*args, &proc|
          ::Specular::Evaluator.new(true, self, __method__, args.first, &proc)
        end
      end

      NEGATIVE_ASSERT_ALIASES.each do |meth|
        define_method meth do |*args, &proc|
          ::Specular::Evaluator.new(false, self, __method__, args.first, &proc)
        end
      end

      def __specular__total_assertions__ op = nil
        __specular__.total_assertions += 1 if op == :+
        __specular__.total_assertions
      end

      def __specular__failed_assertions__ assertion = nil, error = nil
        __specular__.failed_assertions[__specular__context__.dup] = [
            (__specular__current_spec__ || {})[:name],
            (__specular__current_test__ || {})[:name],
            assertion,
            error,
            __specular__nesting_level__
        ] if assertion
        __specular__.failed_assertions
      end

    end
    include SpecularAssertMixin

    module SpecularTestMixin

      SPEC_ALIASES.each do |prefix|
        define_method prefix do |*args, &proc|
          __specular__define_test__ prefix, *args, &proc
        end
      end

      def __specular__define_test__ prefix, *args, &proc

        proc || raise('--- tests need a proc to run ---')

        opts = args.last.is_a?(Hash) ? args.pop : {}
        goal = args.shift
        name = [prefix, goal].join(' ')

        prev_test = __specular__current_test__
        this_test = {:name => name, :proc => proc,
                     :spec => (__specular__current_spec__||{})[:name],
                     :ident => __specular__nesting_level__}

        if (skip = opts[:skip]) && (skip.is_a?(Proc) ? skip.call : true)
          return __specular__skipped_tests__ << this_test
        end

        __specular__current_test__ this_test
        __specular__total_tests__ :+
        __specular__nesting_level__ :+
        __specular__context__ << proc
        __specular__output__(name)

        # executing :before hooks
        execute_hooks = opts.has_key?(:hooks) ?
            opts[:hooks] == :before :
            true
        execute_hooks &&
            __specular__hooks__(:a).each { |hook| self.instance_exec(goal, opts, &hook) }

        catch __specular__fail_symbol__ do
          self.instance_exec &proc
        end

        # executing :after hooks
        execute_hooks = opts.has_key?(:hooks) ?
            opts[:hooks] == :after :
            true
        execute_hooks &&
            __specular__hooks__(:z).each { |hook| self.instance_exec(goal, opts, &hook) }

        __specular__context__.pop
        __specular__nesting_level__ :-

        __specular__current_test__ prev_test

      end

      def __specular__current_test__ *args
        __specular__.current_test = args.first if args.size > 0
        __specular__.current_test
      end

      def __specular__total_tests__ op = nil
        __specular__.total_tests += 1 if op == :+
        __specular__.total_tests
      end

      def __specular__skipped_tests__
        __specular__.skipped_tests
      end

    end
    include SpecularTestMixin

    class OutputProxy < Array
      attr_reader :host

      def initialize host
        @host = host
      end

      [:info, :success, :warn, :alert, :error].each do |meth|
        define_method meth do |snippet|
          self << [snippet.to_s, host.__specular__nesting_level__, __method__]
        end
      end

      def last_error
        self.error host.__specular__last_error__[:message]
      end

      def br
        self << ['']
      end
    end

  end
end
