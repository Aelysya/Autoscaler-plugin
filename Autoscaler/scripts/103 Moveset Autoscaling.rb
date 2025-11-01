module PFM
  class Autoscaler
    # Adjust the moveset according to the level
    # @param level [Integer] level of the encounter
    # @param symbol [Symbol] db_symbol of the species
    # @return [Array<Symbol>] adjusted moveset
    def autoscale_moveset_up
      log_debug("Starting moveset autoscaling for species #{@species}.")
      data = data_creature_form(@species, @form)
      level_learnset = data.move_set.select { |move| move.level_learnable? && move.level <= @level }
      moveset = []

      keep_non_level_up = !$game_switches[@config.allow_non_level_up_moves_replacing_switch]
      keep_status = !$game_switches[@config.allow_status_moves_replacing_switch]
      keep_same_type = !$game_switches[@config.allow_different_type_moves_replacing_switch]

      @moves.each do |move|
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

          lvl_move_data.category == move_data.category &&
            lvl_move_data.type == move_data.type &&
            lvl_move.level > (level_learnset.find { |m| m.move == move }&.level || 0)
        end

        next moveset << move if better_same_type_moves.empty?

        moveset << better_same_type_moves.last.move
      end

      moveset << :__undef__ while moveset.size < 4
      @moves = moveset
    end
  end
end
