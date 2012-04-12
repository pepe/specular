module Spine
  class << self

    def task *args, &proc
      tasks[proc] = args
    end

    alias vertebra task

    def tasks
      @tasks ||= {}
    end

    def new opts = {}
      Spine::Frontend.new(tasks, opts)
    end
  end
end

lib = File.expand_path('../spine', __FILE__) << '/'

%w[
utils
task/*
frontend
evaluator
].each { |r| Dir[lib + r + '.rb'].each { |f| require f } }
