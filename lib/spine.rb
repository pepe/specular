module Spine
  class << self

    def task label = nil, &proc
      tasks[proc] = label.to_s
    end

    alias vertebra task

    def tasks
      @tasks ||= {}
    end

    def run *args
      opts = args.last.is_a?(Hash) ? args.pop : {}
      tasks = args.size > 0 ?
          tasks().select { |p, l| args.select { |a| a.is_a?(Regexp) ? l =~ a : l == a.to_s }.size > 0 } :
          tasks()
      Spine::Frontend.new(tasks, opts).run
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
