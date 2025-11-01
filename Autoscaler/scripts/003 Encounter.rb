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
          return super if context == :wild && !$game_switches[Configs.autoscaler.allow_wild_battles_scaling_switch]
          return super if context == :quest && !$game_switches[Configs.autoscaler.allow_quest_rewards_scaling_switch]
          return super if context == :ally && !$game_switches[Configs.autoscaler.allow_ally_trainers_scaling_switch]

          autoscaler = PFM::Autoscaler.new(self, context)
          (level, species, form, moves) = autoscaler.autoscale

          extra[:moves] = moves
          return PFM::Pokemon.new(species, level, shiny_setup.shiny, shiny_setup.not_shiny, form, extra)
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
