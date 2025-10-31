module Studio
  class Group
    class Encounter
      module AutoscalerPlugin
        # Convert the encounter to an actual creature
        # @param level [Integer] level generated through outside factor (ability / other)
        # @return [PFM::Pokemon]
        def to_creature(level = nil)
          return super unless $game_switches[Configs.autoscaler.global_activation_switch]

          # autoscaler = Autoscaler.new(self, $game_temp.autoscaling_context)

          # return autoscaler.autoscale

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
          if reference_level == -1
            log_error('[Autoscaler] - Invalid scaling reference, check your configuration.')
            return PFM::Pokemon.new(specie, base_level, shiny_setup.shiny, shiny_setup.not_shiny, generic_form_generation, extra)
          end

          level = autoscale_level(base_level, reference_level)
          symbol = specie

          if level > base_level
            symbol = autoscale_evolution_up(level) if $game_switches[Configs.autoscaler.allow_evolution_scaling_switch]
            extra[:moves] = autoscale_moveset_up(level, symbol) if $game_switches[Configs.autoscaler.allow_moveset_scaling_switch]
          end

          if level < base_level
            symbol = autoscale_evolution_down(level) if $game_switches[Configs.autoscaler.allow_evolution_scaling_down_switch]
            # extra[:moves] = autoscale_moveset_down(level, symbol) if $game_switches[Configs.autoscaler.allow_moveset_scaling_switch]
          end

          return PFM::Pokemon.new(symbol, level, shiny_setup.shiny, shiny_setup.not_shiny, generic_form_generation, extra)
        end

        # Calculate the reference level based on the current configuration
        # @return [Integer] reference level
        def calc_reference_level
          scaling_mode = $game_variables[Configs.autoscaler.scaling_mode_variable]
          flat_modifier = $game_variables[Configs.autoscaler.flat_level_modifier_variable]
          player_party = $actors

          reference_level = -1

          case scaling_mode
          when 0 # Average
            total_level = player_party.sum(&:level)
            reference_level = (total_level / player_party.size.to_f).round
          when 1 # Party highest
            reference_level = player_party.map(&:level).max
          when 2 # Overall highest
            levels = []
            levels << player_party.map(&:level).max
            block = proc { |creature| levels << creature.level }
            $storage.each_pokemon(&block)
            reference_level = levels.max
          when 3 # Manual
            manual_target = $game_variables[Configs.autoscaler.manual_target_level_variable]
            reference_level = manual_target > 0 ? manual_target : -1
          else
            reference_level = -1
          end

          reference_level += flat_modifier
          return reference_level
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
        def autoscale_evolution_up(level)
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

        # Change the Pokémon species for one of it's pre-evolutions if its level is low enough
        # @param level [Integer] level of the encounter
        # @return [Symbol] species db_symbol
        def autoscale_evolution_down(level)
          data = data_creature_form(specie, form)
          baby_db_symbol = data.baby_db_symbol
          return specie if baby_db_symbol.nil? || specie == baby_db_symbol

          baby_evolutions = data_creature_form(baby_db_symbol, data.baby_form).evolutions
          evolution = nil
          previous_species_symbol = nil
          if baby_evolutions.any? { |evo| evo.db_symbol == specie && evo.form == form }
            evolution = baby_evolutions.find { |evo| evo.db_symbol == specie && evo.form == form }
            previous_species_symbol = baby_db_symbol
          else
            evolution = baby_evolutions.find do |evo|
              evo_data = data_creature_form(evo.db_symbol, evo.form)
              evo_data.evolutions.find { |evo| evo.db_symbol == specie && evo.form == form }
            end
            previous_species_symbol = evolution.db_symbol
          end

          index = data.evolutions.select { |evo| evo.condition_data(:gemme).nil? }.empty? ? 1 : 0

          if (evolution.condition_data(:minLevel).nil? && evolution.condition_data(:minLevel) > level) ||
             (evolution.condition_data(:stone).nil? && Configs.autoscaler.stone_evolution_levels[index] > level) ||
             (evolution.condition_data(:trade).nil? && Configs.autoscaler.trade_evolution_levels[index] > level) ||
             (evolution.condition_data(:minLoyalty).nil? && Configs.autoscaler.loyalty_evolution_levels[index] > level) ||
             (evolution.condition_data(:itemHold).nil? && Configs.autoscaler.item_held_evolution_levels[index] > level)

            # return previous_species_symbol
          end
        end

        # Adjust the moveset according to the level
        # @param level [Integer] level of the encounter
        # @param symbol [Symbol] db_symbol of the species
        # @return [Array<Symbol>] adjusted moveset
        def autoscale_moveset_up(level, symbol)
          data = data_creature_form(symbol, form)
          level_learnset = data.move_set.select { |move| move.level_learnable? && move.level <= level }
          moveset = []

          keep_non_level_up = !$game_switches[Configs.autoscaler.allow_non_level_up_moves_replacing_switch]
          keep_status = !$game_switches[Configs.autoscaler.allow_status_moves_replacing_switch]
          keep_same_type = !$game_switches[Configs.autoscaler.allow_different_type_moves_replacing_switch]

          extra[:moves].each do |move|
            next if move == :__undef__
            next moveset << move if move == :__remove__

            move_data = data_move(move)

            next moveset << move if keep_non_level_up && !level_learnset.map(&:move).include?(move_data.db_symbol)

            if move_data.category == :status
              moveset << move if keep_status
              next
            end

            next unless keep_same_type

            better_same_type_moves = level_learnset.select do |lvl_move|
              lvl_move_data = data_move(lvl_move.move)

              %i[physical special].include?(lvl_move_data.category) &&
                lvl_move_data.type == move_data.type &&
                lvl_move.level > (level_learnset.find { |m| m.move == move }&.level || 0)
            end

            next moveset << move if better_same_type_moves.empty?

            moveset << better_same_type_moves.last.move
          end

          until moveset.size >= 4
            next moveset << level_learnset.pop.move if level_learnset.any?

            moveset << :__remove__
          end

          return moveset
        end
      end
      prepend AutoscalerPlugin
    end
  end
end
