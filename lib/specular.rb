require 'specular/utils'
require 'specular/spec'
require 'specular/evaluator'

class Spec
  # any argument provided here will be passed inside block.
  # use convenient names to read them
  #
  # @example
  #    Spec.new NewsController, NewsModel, :status => 1 do |controller, model, filter|
  #      item = model.find filter
  #      action = controller.http.route action
  #    end
  #
  def self.new *args, &proc
    ::Specular.spec *args, &proc
  end
end

class Specular

  include Utils

  class << self

    def spec *args, &proc
      specs << [args, proc]
    end

    def specs
      @specs ||= []
    end

    def run *args
      new.run *args
    end

  end

  def initialize &proc
    @hooks = {}
    @output = []
    @skipped_specs = []
    @total_tests, @skipped_tests = 0, []
    @total_assertions, @failed_assertions = 0, {}
    self.instance_exec(&proc) if proc
  end

  def boot &proc
    @hooks[:boot] = proc
  end

  def halt &proc
    @hooks[:halt] = proc
  end

  def before &proc
    @hooks[:before] = proc
  end

  def after &proc
    @hooks[:after] = proc
  end

  def run *args
    @opts = args.last.is_a?(Hash) ? args.pop : {}
    @specs = args.size > 0 ?
        self.class.specs().select { |t| args.select { |a| t=t.first.first.to_s; a.is_a?(Regexp) ? t =~ a : t == a.to_s }.size > 0 } :
        self.class.specs()

    @specs.each do |spec|

      spec_args, spec_proc = spec
      spec_class = Class.new { include ::Specular::Spec }
      spec_instance = spec_class.new

      (h = @hooks[:boot]) && spec_class.class_exec(&h)
      (h = @hooks[:before]) && spec_instance.instance_exec(&h)

      spec_instance.__specular__run__ *spec_args, &spec_proc

      (h = @hooks[:after]) && spec_instance.instance_exec(&h)
      (h = @hooks[:halt]) && spec_class.class_exec(&h)

      @output.concat spec_instance.__specular__output__

      @skipped_specs += spec_instance.__specular__skipped_specs__

      @total_tests += spec_instance.__specular__total_tests__
      @skipped_tests += spec_instance.__specular__skipped_tests__

      @total_assertions += spec_instance.__specular__total_assertions__
      @failed_assertions.update spec_instance.__specular__failed_assertions__
    end
    self
  end

  def passed?
    failed == 0
  end

  def failed?
    failed > 0
  end

  def exit_code
    passed? ? 0 : 1
  end

  def failed
    @failed_assertions.size
  end

  def output
    reset_stdout
    @output.each { |setup| stdout *setup }
    stdout
  end

  def skipped_specs
    reset_stdout
    return stdout unless @skipped_specs.size > 0
    nl; stdout "--- Skipped Specs ---", 0, :alert
    @skipped_specs.each do |t|
      nl
      stdout '%s at %s' % [t[:name], proc_source(t[:proc])]
    end
    stdout
  end

  def skipped_tests
    reset_stdout
    return stdout unless @skipped_tests.size > 0
    nl; stdout "--- Skipped Tests ---", 0, :alert
    @skipped_tests.each do |t|
      nl
      stdout t[:spec]
      stdout '%s at %s' % [t[:name], proc_source(t[:proc])], t[:ident] - 1
    end
    stdout
  end

  def failures
    reset_stdout
    return stdout unless @failed_assertions.size > 0
    nl; stdout "--- Failed Tests ---", 0, :warn
    backtrace_alert = nil
    nl
    @failed_assertions.each_value do |setup|

      spec, test, assertion, error, ident = setup

      nl
      stdout spec
      stdout test, ident
      stdout [Colorize.alert(assertion), error[:source]].join(' at '), ident

      if (exception = error[:exception]).is_a?(Exception)
        stdout exception.message, ident, :error
        if backtrace = exception.backtrace
          if @opts[:trace]
            backtrace.each { |s| stdout s, ident }
          else
            backtrace_alert = true
          end
        end
      else
        message = error[:message] ?
            Colorize.error(error[:message].to_s.strip) :
            '%s %s %s %s' % [
                Colorize.warn(error[:proxy]),
                expected_vs_received(error[:object]),
                Colorize.warn(error[:method]),
                expected_vs_received(*error[:expected])
            ]
        stdout message, ident
      end
      (details = error[:details]) &&
          details.each { |e| stdout e[0], ident, e[1] }

    end

    nl
    stdout 'use `:trace => true` to see error details' if backtrace_alert
    stdout
  end

  def summary
    reset_stdout
    nl; stdout '---'
    stdout 'Specs:       %s%s' % [@specs.size, @skipped_specs.size > 0 ? ' (%s skipped)' % @skipped_specs.size : '']
    stdout 'Tests:       %s%s' % [@total_tests, @skipped_tests.size > 0 ? ' (%s skipped)' % @skipped_tests.size : '']
    stdout 'Assertions:  %s%s' % [@total_assertions, passed? ? '' : ' (%s failed)' % failed], 0, passed? ? :success : :error
    stdout
  end

  def to_s
    (output + skipped_specs + skipped_tests + failures + summary).join("\n")
  end

  private
  def nl
    stdout ''
  end

  def reset_stdout
    @stdout = []
  end

  def stdout chunk = nil, ident = 0, color = nil
    unless chunk
      output = (@stdout||reset_stdout)

      def output.to_s
        self.join("\n")
      end

      return output
    end
    str = [' '*(2* (ident > 0 ? ident : 0)), chunk].join
    (@stdout||reset_stdout) << (color ? Colorize.send(color, str) : str)
  end

  def expected_vs_received *objects
    objects.map do |obj|
      [NilClass, String, Symbol].include?(obj.class) ? obj.inspect : obj
    end.join(', ')
  end

end
