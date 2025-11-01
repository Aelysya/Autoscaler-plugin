module PFM
  class Autoscaler
    private

    # Find the reference level
    # @return [Boolean] whether a valid reference level was found
    def calc_reference_level
      scaling_mode = $game_variables[@config.scaling_mode_variable]
      player_party = $actors

      case scaling_mode
      when 0 # Average
        log_debug('Calculating reference level using "Average" mode.')
        total_level = player_party.sum(&:level)
        @reference_level = (total_level / player_party.size.to_f).round
      when 1 # Party highest
        log_debug('Calculating reference level using "Highest level in party" mode.')
        @reference_level = player_party.map(&:level).max
      when 2 # Overall highest
        log_debug('Calculating reference level using "Highest level overall" mode.')
        levels = []
        levels << player_party.map(&:level).max
        block = proc { |creature| levels << creature.level }
        $storage.each_pokemon(&block)
        @reference_level = levels.max
      when 3 # Manual
        log_debug('Calculating reference level using "Manual" mode.')
        manual_target = $game_variables[@config.manual_target_level_variable]
        if manual_target > 0
          @reference_level = manual_target
        else
          return false
        end
      else
        return false
      end

      log_debug("Reference level calculated: #{@reference_level}")
      return true
    end

    # Autoscale the level
    # @return [Symbol] The direction of the autoscaling (:up, :down, :none)
    def autoscale_level
      level_difference = @reference_level - @level + $game_variables[@config.flat_level_modifier_variable]
      if level_difference < 0 && !$game_switches[@config.allow_level_scaling_down_switch]
        log_debug('Scaling down level is not allowed. Stopping autoscale.')
        return :none
      end

      if level_difference == 0
        log_debug('No level difference detected. Stopping autoscale.')
        return :none
      end

      max_change = $game_variables[@config.maximum_levels_to_scale_variable]
      @level += level_difference.clamp(-max_change, max_change)
      @level = @level.clamp(1, Configs.settings.max_level)

      log_debug("Level autoscaled to #{@level}.")

      return level_difference > 0 ? :up : :down
    end
  end
end
