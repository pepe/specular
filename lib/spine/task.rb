module Spine
  module Task

    module SpineBaseMixin

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
        @__spine__vars_pool__ = Struct.new(*vars.keys).new(*vars.values)

        catch __spine__skip_symbol__ do

          (skip = opts[:skip]) &&
              (skip.is_a?(Proc) ? skip.call && __spine__skip_task! : __spine__skip_task!)

          __spine__output__ ''
          __spine__output__ name

          catch __spine__fail_symbol__ do
            self.instance_exec *args, &proc
          end
        end
      end

      def __spine__output__ snippet = nil, color = nil
        __spine__.output << [snippet.to_s, __spine__nesting_level__, color].compact if snippet
        __spine__.output
      end

      def __spine__context__
        __spine__.context
      end

      def __spine__current_task__
        __spine__.current_task
      end

      def __spine__skipped_tasks__
        __spine__.skipped_tasks
      end

      def __spine__skip_task!
        __spine__skipped_tasks__ << __spine__current_task__
        throw __spine__skip_symbol__
      end

      def __spine__source_files__
        __spine__.source_files
      end

      def __spine__last_error__
        (__spine__failed_assertions__.values.last || [])[4] || {}
      end

      def __spine__skip_symbol__
        ('__spine__skip_symbol__%s__' % __spine__context__.dup.last).to_sym
      end

      def __spine__fail_symbol__
        ('__spine__fail_symbol__%s__' % __spine__context__.dup.last).to_sym
      end

      def __spine__hooks__ position
        __spine__.hooks[position].map do |map|
          context, hook = map
          hook if __spine__context__[0, context.size] == context
        end.compact
      end

      def __spine__nesting_level__ op = nil
        __spine__.nesting_level += 1 if op == :+
        __spine__.nesting_level -= 1 if op == :-
        __spine__.nesting_level
      end

      private
      def __spine__
        @__spine__vars_pool__
      end

    end
    include SpineBaseMixin

    module SpineFrontendMixin

      def include mdl
        self.class.class_exec { include mdl }
      end

      def o s = nil
        return __spine__.output.info(s) if s
        __spine__.output
      end

      alias d o

      # blocks to be executed before/after each test.
      #
      # please note that in case of nested tests,
      # children will override variables set by parents.
      # @example
      #    Spine.task do
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
        __spine__.hooks[:a] << [__spine__context__.dup, proc]
      end

      def after &proc
        __spine__.hooks[:z] << [__spine__context__.dup, proc]
      end

    end
    include SpineFrontendMixin

    module SpineAssertMixin

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

      def __spine__total_assertions__ op = nil
        __spine__.total_assertions += 1 if op == :+
        __spine__.total_assertions
      end

      def __spine__failed_assertions__ assertion = nil, error = nil
        __spine__.failed_assertions[__spine__context__.dup] = [
            (__spine__current_task__ || {})[:name],
            (__spine__current_test__ || {})[:name],
            assertion,
            error,
            __spine__nesting_level__
        ] if assertion
        __spine__.failed_assertions
      end

    end
    include SpineAssertMixin

    module SpineTestMixin

      [:Should,
       :Spec, :Describe,
       :Test, :Testing,
       :Given, :When, :Then,
       :It, :He, :She,
       :If, :Let, :Say, :Assume, :Suppose,
       :And, :Or, :Nor, :But, :However].each do |prefix|
        define_method prefix do |*args, &proc|
          __spine__define_test__ prefix, *args, &proc
        end
      end

      def __spine__define_test__ prefix, goal, opts = {}, &proc

        proc || raise('--- tests need a proc to run ---')

        name = [prefix, goal].join(' ')

        prev_test = __spine__current_test__
        __spine__current_test__ :name => name,
                                :proc => proc,
                                :task => (__spine__current_task__||{})[:name],
                                :ident => __spine__nesting_level__

        catch __spine__skip_symbol__ do

          (skip = opts[:skip]) &&
              (skip.is_a?(Proc) ? skip.call && __spine__skip_test! : __spine__skip_test!)

          __spine__total_tests__ :+
          __spine__nesting_level__ :+
          __spine__context__ << proc
          __spine__output__(name)

          # executing :before hooks
          __spine__hooks__(:a).each { |hook| self.instance_exec(goal, opts, &hook) }

          catch __spine__fail_symbol__ do
            self.instance_exec &proc
          end

          # executing :after hooks
          __spine__hooks__(:z).each { |hook| self.instance_exec(goal, opts, &hook) }

          __spine__context__.pop
          __spine__nesting_level__ :-

        end
        __spine__current_test__ prev_test

      end

      def __spine__current_test__ *args
        __spine__.current_test = args.first if args.size > 0
        __spine__.current_test
      end

      def __spine__total_tests__ op = nil
        __spine__.total_tests += 1 if op == :+
        __spine__.total_tests
      end

      def __spine__skipped_tests__
        __spine__.skipped_tests
      end

      def __spine__skip_test!
        __spine__skipped_tests__ << __spine__current_test__
        throw __spine__skip_symbol__
      end

    end
    include SpineTestMixin

    class OutputProxy < Array
      attr_reader :host

      def initialize host
        @host = host
      end

      [:info, :success, :warn, :alert, :error].each do |meth|
        define_method meth do |snippet|
          self << [snippet.to_s, host.__spine__nesting_level__, __method__]
        end
      end

      def last_error
        self.error host.__spine__last_error__[:message]
      end

      def br
        self << ['']
      end
    end

  end
end
