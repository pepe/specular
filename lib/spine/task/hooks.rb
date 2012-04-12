module Spine
  module Task

    def before &proc
      @__spine__vars_pool__.hooks[:a][spine__context.dup] = proc
    end

    def after &proc
      @__spine__vars_pool__.hooks[:z][spine__context.dup] = proc
    end

    def spine__hooks position
      @__spine__vars_pool__.hooks[position].map do |context, hook|
        hook if spine__context[0, context.size] == context
      end.compact
    end

  end
end
