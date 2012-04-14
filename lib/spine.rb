module Spine
  class << self

    def task *args, &proc
      opts = args.last.is_a?(Hash) ? args.pop : {}
      tasks << [args.first.to_s, opts, proc]
    end

    alias vertebra task

    def tasks
      @tasks ||= []
    end

    def run *args
      opts = args.last.is_a?(Hash) ? args.pop : {}
      tasks = args.size > 0 ?
          tasks().select { |t| args.select { |a| a.is_a?(Regexp) ? t[0] =~ a : t[0] == a.to_s }.size > 0 } :
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
