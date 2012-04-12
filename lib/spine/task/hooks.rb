module Spine
  class Task

    def before &proc
      (@__spine__vars_pool__.hooks[:a][current_scenario[:proc]||'*']||=[]) << proc if proc
    end

    def after &proc
      (@__spine__vars_pool__.hooks[:z][current_scenario[:proc]||'*']||=[]) << proc if proc
    end

    # each scenario has own hooks. upper hooks wont be inherited.
    def spine__hooks position
      [
          (@__spine__vars_pool__.hooks[position]['*']),
          #(@__spine__vars_pool__.hooks[position][spine__current_scenario[:proc]] if spine__current_scenario)
      ].uniq.flatten.compact
    end

  end
end
