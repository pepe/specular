module Spine
  module Task

    class OutputProxy < Array
      attr_reader :host

      def initialize host
        @host = host
      end

      [:info, :success, :warn, :alert, :error].each do |meth|
        define_method meth do |snippet|
          return if host.spine__context_skipped?
          self << [snippet.to_s, host.spine__nesting_level, __method__]
        end
      end

      define_method :last_error do
        self.error host.spine__last_error[:message]
      end

      def br
        self << ['']
      end
    end

    def initialize *args, &proc

      proc || raise('--- tasks need a proc to run ---')

      opts = args.last.is_a?(Hash) ? args.pop : {}
      name = args.first

      output = OutputProxy.new self

      vars = {
          :nesting_level => 0, :context => [],
          :output => output, :source_files => {},
          :current_task => {:name => name, :proc => proc}, :skipped_tasks => {},
          :current_spec => nil, :total_specs => 0, :skipped_specs => {},
          :current_test => nil, :total_tests => 0, :skipped_tests => {},
          :assertion_passed => true, :total_assertions => 0, :failed_assertions => {},
          :hooks => {:a => [], :z => []}, :browser => nil
      }
      @__spine__vars_pool__ = Struct.new(*vars.keys).new(*vars.values)

      if opts[:skip]
        spine__task_skipped
      else
        spine__output ''
        spine__output name
      end

      catch spine__halting_symbol do
        self.instance_exec *args, &proc
      end
    end

    def spine__last_error
      (spine__failed_assertions.values.last || [])[4] || {}
    end

    def include mdl
      self.class.class_exec { include mdl }
    end

    def o s = nil
      return @__spine__vars_pool__.output.info(s) if s
      @__spine__vars_pool__.output
    end

    alias d o

    def spine__output snippet = nil, color = nil
      @__spine__vars_pool__.output << [snippet.to_s, spine__nesting_level, color].compact if snippet
      @__spine__vars_pool__.output
    end

    def spine__context
      @__spine__vars_pool__.context
    end

    def spine__context_skipped?
      spine__task_skipped? || spine__spec_skipped? || spine__test_skipped?
    end

    def spine__current_task
      @__spine__vars_pool__.current_task
    end

    def spine__skipped_tasks
      @__spine__vars_pool__.skipped_tasks
    end

    def spine__task_skipped
      spine__skipped_tasks[spine__context.dup] = spine__current_task
    end

    def spine__task_skipped?
      spine__skipped_tasks.each_key do |context|
        return true if spine__context[0, context.size] == context
      end
      nil
    end

    def spine__source_files
      @__spine__vars_pool__.source_files
    end

    def spine__failures?
      spine__failed_assertions.each_key do |context|
        return true if spine__context[0, context.size] == context
      end
      nil
    end

    def spine__halting_symbol
      ('spine__halting_symbol__%s' % spine__context.dup.last).to_sym
    end

    def spine__nesting_level op = nil
      @__spine__vars_pool__.nesting_level += 1 if op == :+
      @__spine__vars_pool__.nesting_level -= 1 if op == :-
      @__spine__vars_pool__.nesting_level
    end

  end
end
