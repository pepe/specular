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
    ::Specular.tasks << [args, proc]
  end
end

module Specular
  class << self

    def tasks
      @tasks ||= []
    end

    def run *args
      @opts = args.last.is_a?(Hash) ? args.pop : {}
      tasks = args.size > 0 ?
          tasks().select { |t| args.select { |a| t=t.first.first.to_s; a.is_a?(Regexp) ? t =~ a : t == a.to_s }.size > 0 } :
          tasks()
      ::Specular::Frontend.new(tasks, @opts).run
    end

    private
    attr_reader :opts
  end
end

require 'specular/utils'
require 'specular/assert'
require 'specular/task'
require 'specular/frontend'
