module Spine
  module Task

    # blocks to be executed before/after each test.
    #
    # hooks can be defined inside tasks and specs.
    # it does not make sense to define hooks inside tests.
    #
    # please note that in case of nested tests,
    # children will override variables set by parents.
    # @example
    #    Spine.task do
    #
    #      before do
    #        @n = 0
    #      end
    #
    #      Test :Nr1 do
    #
    #        # @n is 0
    #        @n += 1 # @n is 1
    #
    #        Test :Nr1_1 do
    #          # @n is 0
    #        end
    #
    #        # @n is 0 cause it was override by Test Nr1_1
    #      end
    #
    #    end
    #
    def before &proc
      raise('--- hooks can not be defined inside tests ---') if spine__current_test
      @__spine__vars_pool__.hooks[:a][spine__context.dup] = proc
    end

    def after &proc
      raise('--- hooks can not be defined inside tests ---') if spine__current_test
      @__spine__vars_pool__.hooks[:z][spine__context.dup] = proc
    end

    def spine__hooks position
      @__spine__vars_pool__.hooks[position].map do |context, hook|
        hook if spine__context[0, context.size] == context
      end.compact
    end

  end
end
