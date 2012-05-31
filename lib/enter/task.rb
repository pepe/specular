module Enter
  module Task

    module EnterBaseMixin

      def initialize *args, &proc

        proc || raise('--- tasks need a proc to run ---')

        opts = args.last.is_a?(Hash) ? args.pop : {}
        name = args.first

        output = OutputProxy.new self

        vars = {
            :nesting_level => 0, :context => [],
            :output => output, :source_files => {},
            :current_task => {:name => name, :proc => proc}, :skipped_tasks => [],
            :current_test => nil, :total_tests => 0, :skipped_tests => [],
            :total_assertions => 0, :failed_assertions => {},
            :hooks => {:a => [], :z => []}, :browser => nil
        }
        @__enter__vars_pool__ = Struct.new(*vars.keys).new(*vars.values)

        if (skip = opts[:skip]) && (skip.is_a?(Proc) ? skip.call : true)
          return __enter__skipped_tasks__ << __enter__current_task__
        end

        __enter__output__ ''
        __enter__output__ name

        catch __enter__fail_symbol__ do
          self.instance_exec *args, &proc
        end

      end

      def __enter__output__ snippet = nil, color = nil
        __enter__.output << [snippet.to_s, __enter__nesting_level__, color].compact if snippet
        __enter__.output
      end

      def __enter__context__
        __enter__.context
      end

      def __enter__current_task__
        __enter__.current_task
      end

      def __enter__skipped_tasks__
        __enter__.skipped_tasks
      end

      def __enter__source_files__
        __enter__.source_files
      end

      def __enter__last_error__
        (__enter__failed_assertions__.values.last || [])[4] || {}
      end

      def __enter__fail_symbol__
        ('__enter__fail_symbol__%s__' % __enter__context__.dup.last).to_sym
      end

      def __enter__hooks__ position
        __enter__.hooks[position].map do |map|
          context, hook = map
          hook if __enter__context__[0, context.size] == context
        end.compact
      end

      def __enter__nesting_level__ op = nil
        __enter__.nesting_level += 1 if op == :+
        __enter__.nesting_level -= 1 if op == :-
        __enter__.nesting_level
      end

      private
      def __enter__
        @__enter__vars_pool__
      end

    end
    include EnterBaseMixin

    module EnterFrontendMixin

      def include mdl
        self.class.class_exec { include mdl }
      end

      def o s = nil
        return __enter__.output.info(s) if s
        __enter__.output
      end

      alias d o

      # blocks to be executed before/after each test.
      #
      # please note that in case of nested tests,
      # children will override variables set by parents.
      # @example
      #    Enter.task do
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
        __enter__.hooks[:a] << [__enter__context__.dup, proc]
      end

      def after &proc
        __enter__.hooks[:z] << [__enter__context__.dup, proc]
      end

    end
    include EnterFrontendMixin

    module EnterAssertMixin

      [:is, :is?, :are, :are?, :does, :does?, :expect, :assert, :check].each do |meth|
        define_method meth do |*args, &proc|
          ::Enter::Assert.new(true, self, __method__, args.first, &proc)
        end
      end

      [:refute, :false?].each do |meth|
        define_method meth do |*args, &proc|
          ::Enter::Assert.new(false, self, __method__, args.first, &proc)
        end
      end

      def __enter__total_assertions__ op = nil
        __enter__.total_assertions += 1 if op == :+
        __enter__.total_assertions
      end

      def __enter__failed_assertions__ assertion = nil, error = nil
        __enter__.failed_assertions[__enter__context__.dup] = [
            (__enter__current_task__ || {})[:name],
            (__enter__current_test__ || {})[:name],
            assertion,
            error,
            __enter__nesting_level__
        ] if assertion
        __enter__.failed_assertions
      end

    end
    include EnterAssertMixin

    module EnterTestMixin

      [:Should, :Spec, :Describe, :Context,
       :Test, :Testing, :Set, :Setting,
       :Given, :When, :Then,
       :It, :He, :She,
       :If, :Let, :Say, :Assume, :Suppose,
       :And, :Or, :Nor, :But, :However].each do |prefix|
        define_method prefix do |*args, &proc|
          __enter__define_test__ prefix, *args, &proc
        end
      end

      def __enter__define_test__ prefix, *args, &proc

        proc || raise('--- tests need a proc to run ---')

        opts = args.last.is_a?(Hash) ? args.pop : {}
        goal = args.shift
        name = [prefix, goal].join(' ')

        prev_test = __enter__current_test__
        this_test = {:name => name, :proc => proc,
                     :task => (__enter__current_task__||{})[:name],
                     :ident => __enter__nesting_level__}

        if (skip = opts[:skip]) && (skip.is_a?(Proc) ? skip.call : true)
          return __enter__skipped_tests__ << this_test
        end

        __enter__current_test__ this_test
        __enter__total_tests__ :+
        __enter__nesting_level__ :+
        __enter__context__ << proc
        __enter__output__(name)

        # executing :before hooks
        execute_hooks = opts.has_key?(:hooks) ?
            opts[:hooks] == :before :
            true
        execute_hooks &&
            __enter__hooks__(:a).each { |hook| self.instance_exec(goal, opts, &hook) }

        catch __enter__fail_symbol__ do
          self.instance_exec &proc
        end

        # executing :after hooks
        execute_hooks = opts.has_key?(:hooks) ?
            opts[:hooks] == :after :
            true
        execute_hooks &&
            __enter__hooks__(:z).each { |hook| self.instance_exec(goal, opts, &hook) }

        __enter__context__.pop
        __enter__nesting_level__ :-

        __enter__current_test__ prev_test

      end

      def __enter__current_test__ *args
        __enter__.current_test = args.first if args.size > 0
        __enter__.current_test
      end

      def __enter__total_tests__ op = nil
        __enter__.total_tests += 1 if op == :+
        __enter__.total_tests
      end

      def __enter__skipped_tests__
        __enter__.skipped_tests
      end

    end
    include EnterTestMixin

    class OutputProxy < Array
      attr_reader :host

      def initialize host
        @host = host
      end

      [:info, :success, :warn, :alert, :error].each do |meth|
        define_method meth do |snippet|
          self << [snippet.to_s, host.__enter__nesting_level__, __method__]
        end
      end

      def last_error
        self.error host.__enter__last_error__[:message]
      end

      def br
        self << ['']
      end
    end

  end
end
