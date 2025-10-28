module PFM
  class PokemonBattler < Pokemon
    module AutoscalerPlugin
      # Autoscale the battler according to the configuration
      def autoscale
        reference_level = calc_reference_level

        return if reference_level == -1

        autoscale_level(reference_level)
      end

      private

      def calc_reference_level
        current_difficulty = Configs.autoscaler.difficulty_settings[$game_variables[Configs.autoscaler.current_difficulty_setting_variable]]
        scaling_reference = current_difficulty[:scalingReference]
        player_party = @scene.logic.trainer_battlers

        case scaling_reference
        when 'average'
          total_level = player_party.sum(&:level)
          return (total_level / player_party.size.to_f).round
        when 'highest'
          return player_party.map(&:level).max
        when 'manual'
          return $game_variables[Configs.autoscaler.manual_target_level_variable]
        else
          return -1
        end
      end

      def autoscale_level(reference_level)
        level_difference = reference_level - level
        return if level_difference < 0 && !$game_switches[Configs.autoscaler.allow_scale_down_switch]

        maximum_levels_to_scale = $game_variables[Configs.autoscaler.maximum_levels_to_scale_variable]
        target_level = level + level_difference.clamp(-maximum_levels_to_scale, maximum_levels_to_scale)
        max_level = @scene.battle_info.max_level || Configs.settings.max_level
        upper_limit = [target_level, max_level].min.clamp(1, max_level)

        @level = target_level.clamp(1, upper_limit)
        self.hp = hp_rate > 0 ? (max_hp * hp_rate).to_i.clamp(1, max_hp) : 0
      end
    end

    prepend AutoscalerPlugin
  end
end
