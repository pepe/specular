module Spine
  module Task

    def spec name, opts = {}, &proc

      raise('--- specs can not be defined inside specs ---') if spine__current_spec
      raise('--- specs can not be defined inside scenarios ---') if spine__current_scenario

      spine__total_specs :+
      spine__nesting_level :+

      spine__current_spec name: name,
                          proc: proc,
                          task: (spine__current_task||{})[:name]

      spine__context << proc

      spine__spec_skipped if opts[:skip]
      spine__output name unless spine__context_skipped?

      self.instance_exec &proc

      spine__context.pop
      spine__nesting_level :-

      spine__current_spec nil
    end

    def spine__current_spec *args
      @__spine__vars_pool__.current_spec = args.first if args.size > 0
      @__spine__vars_pool__.current_spec
    end

    def spine__total_specs op = nil
      @__spine__vars_pool__.total_specs += 1 if op == :+
      @__spine__vars_pool__.total_specs
    end

    def spine__skipped_specs
      @__spine__vars_pool__.skipped_specs
    end

    def spine__spec_skipped
      spine__skipped_specs[spine__context.dup] = spine__current_spec
    end

    def spine__spec_skipped?
      spine__skipped_specs.each_key do |context|
        return true if spine__context[0, context.size] == context
      end
      nil
    end

  end
end
