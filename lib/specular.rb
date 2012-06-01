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
    opts = args.last.is_a?(Hash) ? args.pop : {}
    specs = args.size > 0 ?
        self.class.specs().select { |t| args.select { |a| t=t.first.first.to_s; a.is_a?(Regexp) ? t =~ a : t == a.to_s }.size > 0 } :
        self.class.specs()
    ::Specular::Frontend.new(specs, opts, @hooks).run
  end

end

require 'specular/utils'
require 'specular/spec'
require 'specular/evaluator'
require 'specular/frontend'
