module Spine
  class Task
    class Evaluator

      def initialize assert_is, host, proxy, object = nil, &proc
        @assert_is, @host, @proxy, @object, @proc =
            assert_is, host, proxy, object, proc

        @negative_keyword = @assert_is == false ? 'NOT' : ''

        # any test is considered failed until it is explicitly passed
        @host.passed? false

        @file, @line = caller[2].split(/\:in\s+`/).first.scan(/(.*)\:(\d+)$/).flatten
        @host.spine__source_files[@file] ||= ::File.readlines(@file)
        @test = @host.spine__source_files[@file][@line.to_i-1].strip

        @host.output @test, :a
        @host.spine__total_tests :+
      end

      def object
        @tested_object ||= if @proc
                             begin
                               @host.instance_exec(&@proc)
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
        is_a_exception_matching = match ? object.to_s =~ (Regexp === match ? match : /#{Regexp.escape match.to_s}/) : nil

        message, proc = '%s expected an error to be raised' % @negative_keyword, lambda { is_a_exception }
        if type && match
          message = ('%s expected an %s error matching "%s" to be raised' % [@negative_keyword, type, match.source])
          proc = lambda { is_a_exception_of_type && is_a_exception_matching }
        elsif type
          message = ('%s expected an %s error to be raised' % [@negative_keyword, type])
          proc = lambda { is_a_exception_of_type }
        elsif match
          message = ('%s expected raised error to match "%s"' % [@negative_keyword, match.source])
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
              caught_value = catch(symbol) { @host.instance_exec(&@proc) }
            rescue => e
              return failed exception: e
            end
          end
          @host.instance_exec(&@proc)
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
          proc = lambda { symbol == caught_symbol && value == caught_value }
        elsif symbol
          message = '%s expected %s [%s] %s to be thrown, got %s [%s]' %
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
        raise('--- specs can not be defined inside tests ---') if meth == :spec
        evaluate(message: 'failed') { @host.send meth, object, *args }
      end

      private

      def evaluate error = {}, &proc

        if @host.spine__failures?
          return @host.output(' - test skipped due to previous failures', :w)
        end

        begin

          # executing :before hooks
          @host.spine__hooks(:a).each { |p| @host.instance_exec(@test, &p) }

          # executing the test
          result = proc.call

          if @assert_is == true ? result : [false, nil].include?(result)
            # marking the test as passed
            @host.passed? true
            @host.output '- passed', :s
          end

          # executing :after hooks
          @host.spine__hooks(:z).each { |p| @host.instance_exec(@test, &p) }

        rescue => e
          error[:exception] = e
        end

        @host.passed? || failed(error)
      end

      def failed error = {}
        @host.output '- failed', :e
        @host.spine__failed_tests @test, error.update(object: object, source: [@file, @line].join(':'))
        false
      end

    end

  end
end
