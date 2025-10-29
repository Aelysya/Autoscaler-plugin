module Studio
  class Group
    class Encounter
      module AutoscalerPlugin
        # Convert the encounter to an actual creature
        # @param level [Integer] level generated through outside factor (ability / other)
        # @return [PFM::Pokemon]
        def to_creature(level = nil)
          return super unless $game_switches[Configs.autoscaler.global_activation_switch]

          context = $game_temp.autoscaling_context
          return super if context == :wild && !$game_switches[Configs.autoscaler.allow_wild_scaling_switch]
          return super if context == :quest && !$game_switches[Configs.autoscaler.allow_quests_reward_scaling_switch]
          return super if context == :ally && !$game_switches[Configs.autoscaler.allow_ally_scaling_switch]

          level ||= rand(level_setup.range)
          return autoscale(level)
        end

        private

        # Autoscale the battler according to the configuration
        # @param base_level [Integer] base level of the encounter
        # @return [PFM::Pokemon]
        def autoscale(base_level)
          reference_level = calc_reference_level
          return if reference_level == -1

          level = autoscale_level(base_level, reference_level)
          symbol = autoscale_evolution(level) if $game_switches[Configs.autoscaler.allow_evolution_scaling_switch] && level != base_level
          extra[:moves] = autoscale_moveset(level, symbol) if $game_switches[Configs.autoscaler.allow_moveset_scaling_switch] && level != base_level

          return PFM::Pokemon.new(symbol, level, shiny_setup.shiny, shiny_setup.not_shiny, generic_form_generation, extra)
        end

        # Calculate the reference level based on the current configuration
        # @return [Integer] reference level
        def calc_reference_level
          current_difficulty = Configs.autoscaler.difficulty_settings[$game_variables[Configs.autoscaler.current_difficulty_setting_variable]]
          scaling_reference = current_difficulty[:scalingReference]
          player_party = $actors

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

        # Autoscale the base level according to the reference level and configuration
        # @param base_level [Integer] base level of the encounter
        # @param reference_level [Integer] reference level to scale towards
        # @return [Integer] scaled level
        def autoscale_level(base_level, reference_level)
          level_difference = reference_level - base_level
          return base_level if level_difference < 0 && !$game_switches[Configs.autoscaler.allow_scale_down_switch]

          maximum_levels_to_scale = $game_variables[Configs.autoscaler.maximum_levels_to_scale_variable]
          level = base_level + level_difference.clamp(-maximum_levels_to_scale, maximum_levels_to_scale)

          return level.clamp(1, Configs.settings.max_level)
        end

        # Change the Pokémon species for one of it's evolutions if its level is high enough
        # @param level [Integer] level of the encounter
        # @return [Symbol] species db_symbol
        def autoscale_evolution(level)
          data = data_creature_form(specie, form)
          evolutions = data.evolutions.select { |evo| evo.condition_data(:gemme).nil? }
          return specie if evolutions.empty?

          index_in_evo_line = specie == data.baby_db_symbol ? 0 : 1

          evolutions.reject! do |evo|
            (!evo.condition_data(:minLevel).nil? && evo.condition_data(:minLevel) > level) ||
              (!evo.condition_data(:gender).nil? && evo.condition_data(:gender) != extra[:gender]) ||
              (!evo.condition_data(:stone).nil? && Configs.autoscaler.stone_evolution_levels[index_in_evo_line] > level) ||
              (!evo.condition_data(:trade).nil? && Configs.autoscaler.trade_evolution_levels[index_in_evo_line] > level) ||
              (!evo.condition_data(:minLoyalty).nil? && Configs.autoscaler.loyalty_evolution_levels[index_in_evo_line] > level) ||
              (!evo.condition_data(:itemHold).nil? && Configs.autoscaler.item_held_evolution_levels[index_in_evo_line] > level)
          end
          return specie if evolutions.empty?

          return evolutions.first.db_symbol
        end

        # Adjust the moveset according to the level
        # @param level [Integer] level of the encounter
        # @param symbol [Symbol] db_symbol of the species
        # @return [Array<Symbol>] adjusted moveset
        def autoscale_moveset(level, symbol)
          data = data_creature_form(symbol, form)
          learnset = data.move_set.select { |move| move.level_learnable? && move.level <= level }.last(4)
          return extra[:moves] if learnset.empty?

          moveset = (extra[:moves] + learnset).uniq
          moveset.reject! { |move| extra[:moves].include?(move) && moveset.size > 4 }
          return moveset.last(4)
        end
      end
      prepend AutoscalerPlugin
    end
  end
end
