module Spine
  class << self

    # any argument provided here will be passed inside block.
    # use convenient names to read them
    #
    # @example
    #    Spine.task NewsController, NewsModel, :status => 1 do |controller, model, filter|
    #      item = model.find filter
    #      action = controller.http.route action
    #    end
    #
    def task *args, &proc
      tasks << [args, proc]
    end

    alias vertebra task

    def tasks
      @tasks ||= []
    end

    def run *args
      @opts = args.last.is_a?(Hash) ? args.pop : {}
      tasks = args.size > 0 ?
          tasks().select { |t| args.select { |a| t=t.first.first.to_s; a.is_a?(Regexp) ? t =~ a : t == a.to_s }.size > 0 } :
          tasks()
      Spine::Frontend.new(tasks, @opts).run
    end

    private
    attr_reader :opts
  end
end

lib = File.expand_path('../spine', __FILE__) << '/'

%w[
utils
assert
task/*
frontend
].each { |r| Dir[lib + r + '.rb'].each { |f| require f } }
