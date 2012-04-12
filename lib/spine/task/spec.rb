module Spine
  module Task

    def spec label, opts = {}, &proc

      raise('--- specs can not be defined inside specs ---') if spine__current_spec
      raise('--- specs can not be defined inside scenarios ---') if spine__current_scenario

      spine__output label
      spine__total_specs :+

      spine__current_spec label: label, proc: proc

      spine__nesting_level :+
      spine__context << proc

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

  end
end
