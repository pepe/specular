class Specular
  class Evaluator

    EVALUATORS = [
        :==, :===, :eql?, :equal?, :=~,
        '!=', '!~', # take care, this 2 methods wont work on ruby1.8
        :>, :>=, :<, :<=, :between?, :zero?,
        :ascii_only?, :empty?, :start_with?, :end_with?, :frozen?, :include?,
        :instance_of?, :is_a?, :kind_of?, :nil?, :respond_to?, :respond_to_missing?,
        :tainted?, :untrusted?, :valid_encoding?,
        :const_defined?, :instance_variable_defined?,
        :private_method_defined?, :protected_method_defined?, :public_method_defined?,
    ].freeze

    def initialize expect_true, spec, proxy, object = nil, &proc
      @expect_true, @spec, @proxy, @object, @proc =
          expect_true, spec, proxy, object, proc

      @negative_keyword = @expect_true ? '' : 'NOT'

      @file, @line = source_location
      @spec.__specular__source_files__[@file] ||= ::File.readlines(@file)
      @assertion = @spec.__specular__source_files__[@file][@line.to_i-1].strip

      @spec.__specular__assertions__ << {:source => [@file, @line]}
    end

    def object
      @tested_object ||= if @proc
                           begin
                             @spec.instance_exec(&@proc)
                           rescue => e
                             e
                           end
                         else
                           @object
                         end
    end

    EVALUATORS.each do |method|
      define_method method do |*expected|
        evaluate(:proxy => @proxy, :method => method, :expected => expected, :negative => method.to_s =~ /!/) do
          object.send method, *expected
        end
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
      evaluate(:message => message, &proc)
    end

    alias raise? raise_error
    alias raise_error? raise_error
    alias to_raise raise_error
    alias to_raise_error raise_error

    def throw_symbol symbol = nil, value = nil

      return failed(:message => '#throw_symbol works only with procs') unless @proc

      caught_symbol, caught_value = nil, nil
      begin
        if symbol && value
          begin
            caught_value = catch(symbol) { @spec.instance_exec(&@proc) }
          rescue => e
            return failed(:exception => e)
          end
        end
        @spec.instance_exec(&@proc)
      rescue => e
        prefix, caught_symbol = e.message.scan(/uncaught throw (\:|"|'|`)(.*)/).flatten
        case prefix
          when ':'
            caught_symbol = caught_symbol.to_sym
          when '`' # ruby 1.8
            caught_symbol = caught_symbol.sub(/'\Z/, '')
            caught_symbol = caught_symbol.to_sym
          else
            caught_symbol = caught_symbol.sub(/#{prefix}$/, '')
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
      evaluate(:message => message, &proc)
    end

    alias throw? throw_symbol
    alias throw_symbol? throw_symbol
    alias to_throw throw_symbol
    alias to_throw_symbol throw_symbol

    def method_missing meth, *args
      @spec.__specular__assertions__.last[:fwd?] = true
      evaluate(:message => 'failed') do
        @spec.send meth, object, *args
      end
      @spec.__specular__assertions__.each { |a| a.delete :fwd? }
    end

    private

    def evaluate context = {}, &proc
      @spec.__specular__nesting_level__ :+
      @spec.__specular__output__ @assertion, :alert

      # any assertion marked as failed until it is explicitly passed
      passed = false

      begin

        result = proc.call # evaluating assertion
        passed = (@expect_true ? result : !result)
        passed && @spec.__specular__output__.success('- passed')

      rescue => e
        context[:exception] = e
      end

      passed || failed(context)
      @spec.__specular__nesting_level__ :-
    end

    def failed error = {}
      source = @spec.__specular__assertions__.select { |a| a.delete :fwd? }
      source.empty? && source << @spec.__specular__assertions__.last
      source.map! { |c| c[:source] }

      @spec.__specular__failed_assertions__ @assertion, error.update(:object => object, :source => source)
      @spec.__specular__output__ '- failed', :error
      throw @spec.__specular__fail_symbol__
    end

    def source_location offset = 0
      ruby_engine = ::Specular::Utils::RUBY_ENGINE
      ln = ruby_engine == 'rbx' || (ruby_engine == 'jruby' && RUBY_VERSION.to_f == 1.9) ? 2 : 3
      file, line = caller[ln + offset].split(/\:in\s+`/).first.scan(/(.*)\:(\d+)$/).flatten
      [file, line]
    end

  end
end
