module PFM
  class PokemonBattler < Pokemon
    module AutoscalerPlugin
      # Autoscale the battler according to the configuration
      def autoscale
        @level = 10
        self.hp = hp_rate > 0 ? (max_hp * hp_rate).to_i.clamp(1, max_hp) : 0
      end
    end

    prepend AutoscalerPlugin
  end
end
