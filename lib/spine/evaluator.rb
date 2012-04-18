module Spine
  class Evaluator

    def initialize assert_is, task, proxy, object = nil, &proc
      @assert_is, @task, @proxy, @object, @proc =
          assert_is, task, proxy, object, proc

      @negative_keyword = @assert_is == false ? 'NOT' : ''

      @file, @line = caller[2].split(/\:in\s+`/).first.scan(/(.*)\:(\d+)$/).flatten
      @task.spine__source_files[@file] ||= ::File.readlines(@file)
      @assertion = @task.spine__source_files[@file][@line.to_i-1].strip

      @task.spine__total_assertions :+
    end

    def object
      @tested_object ||= if @proc
                           begin
                             @task.instance_exec(&@proc)
                           rescue => e
                             e
                           end
                         else
                           @object
                         end
    end

    [
        :==, :===, :eql?, :equal?, :=~, '!=', '!~',
        :>, :>=, :<, :<=, :between?, :zero?,
        :ascii_only?, :empty?, :start_with?, :end_with?, :frozen?, :include?,
        :instance_of?, :is_a?, :kind_of?, :nil?, :respond_to?, :respond_to_missing?,
        :tainted?, :untrusted?, :valid_encoding?,
        :const_defined?, :instance_variable_defined?,
        :private_method_defined?, :protected_method_defined?, :public_method_defined?,
    ].each do |method|
      define_method method do |*expected|
        evaluate(proxy: @proxy, method: method, expected: expected) { object.send(method, *expected.compact) }
      end
    end

    def raise_error *expectations

      type, match = nil
      expectations.each { |a| a.is_a?(Class) ? type = a : match = a }

      is_a_exception = object.is_a? Exception
      is_a_exception_of_type = type ? object.class == type : nil
      is_a_exception_matching = match ? object.to_s =~ (match.is_a?(Regexp) ? match : /#{Regexp.escape match.to_s}/) : nil

      message, proc = '%s expected an error to be raised' % @negative_keyword, lambda { is_a_exception }
      if type && match
        message = ('%s expected an %s error matching "%s" to be raised but an %s error raised with message: %s' % [
            @negative_keyword, type, match.source, object.class, object.to_s
        ])
        proc = lambda { is_a_exception_of_type && is_a_exception_matching }
      elsif type
        message = ('%s expected an %s error to be raised but %s raised instead' % [@negative_keyword, type, object.class])
        proc = lambda { is_a_exception_of_type }
      elsif match
        message = ('%s expected raised error to match "%s"' % [@negative_keyword, match])
        proc = lambda { is_a_exception_matching }
      end
      evaluate message: message, &proc
    end

    alias raise? raise_error
    alias raise_error? raise_error
    alias to_raise raise_error
    alias to_raise_error raise_error

    def throw_symbol symbol = nil, value = nil

      return failed message: '#throw_symbol works only with procs' unless @proc

      caught_symbol, caught_value = nil, nil
      begin
        if symbol && value
          begin
            caught_value = catch(symbol) { @task.instance_exec(&@proc) }
          rescue => e
            return failed exception: e
          end
        end
        @task.instance_exec(&@proc)
      rescue ArgumentError => e
        prefix, caught_symbol = e.message.scan(/uncaught throw (\:|"|')(.*)/).flatten
        if prefix && caught_symbol
          if prefix == ':'
            caught_symbol = caught_symbol.to_sym
          else
            caught_symbol = caught_symbol.sub(prefix, '')
          end
        end
      end

      message, proc = '%s expected an symbol to be thrown' % @negative_keyword, lambda { caught_symbol }
      if symbol && value
        message = '%s expected %s [%s] with value %s [%s] to be thrown, got %s [%s] with value %s [%s]' %
            [@negative_keyword, symbol, symbol.class, value, value.class,
             caught_symbol, caught_symbol.class, caught_value, caught_value.class]
        proc = lambda { symbol == caught_symbol && (value.is_a?(Regexp) ? caught_value.to_s =~ value : caught_value == value) }
      elsif symbol
        message = '%s expected %s [%s] to be thrown, got %s [%s]' %
            [@negative_keyword, symbol, symbol.class, caught_symbol, caught_symbol.class]
        proc = lambda { symbol == caught_symbol }
      end
      evaluate message: message, &proc
    end

    alias throw? throw_symbol
    alias throw_symbol? throw_symbol
    alias to_throw throw_symbol
    alias to_throw_symbol throw_symbol

    def method_missing meth, *args
      evaluate(message: 'failed') { @task.send meth, object, *args }
    end

    private

    def evaluate error = {}, &proc

      return if @task.spine__context_skipped?

      @task.spine__output @assertion, :alert

      if @task.spine__failures?
        return @task.spine__output ' - assertion skipped due to previous failures', :warn
      end

      # any assertion marked as failed until it is explicitly passed
      @task.passed? false

      begin

        # executing :before hooks
        @task.spine__hooks(:a).each { |p| @task.instance_exec(@assertion, &p) }

        # evaluating assertion
        result = proc.call

        if @assert_is == true ? result : [false, nil].include?(result)
          # marking the assertion as passed
          @task.passed? true
          @task.spine__output.success '- passed'
        end

        # executing :after hooks
        @task.spine__hooks(:z).each { |p| @task.instance_exec(@assertion, &p) }

      rescue => e
        error[:exception] = e
      end

      @task.passed? || failed(error)
    end

    def failed error = {}
      @task.spine__failed_assertions @assertion, error.update(object: object, source: [@file, @line].join(':'))
      @task.spine__output '- failed', :error
      false
    end

  end
end
