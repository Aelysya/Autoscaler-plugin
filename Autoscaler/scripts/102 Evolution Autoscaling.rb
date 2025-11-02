module PFM
  class Autoscaler
    # List of unsupported evolution methods for autoscaling
    UNSUPPORTED_EVOLUTION_METHODS = %i[switch gemme]

    CONFIGURED_EVOLUTION_METHODS = %i[stone trade itemHold nature func maps weather env dayNight]

    private

    # Change the Pokémon species for one of it's evolutions if its level is high enough
    def autoscale_evolution_up
      log_debug("Starting evolution autoscaling for species #{@species}.")
      data = data_creature_form(@species, @form)
      evolutions = data.evolutions.dup
      index_in_evo_line = data.baby_db_symbol.nil? || @species == data.baby_db_symbol ? 0 : 1

      evolutions.select! { |evo| check_evolution_validity(evo, index_in_evo_line) }
      if evolutions.empty?
        log_debug('No valid evolutions found. Stopping evolution autoscaling.')
        return
      end

      if evolutions.size == 1
        log_debug("Evolved species #{@species} to #{evolutions.first.db_symbol}.")
        @species = evolutions.first.db_symbol
        @form = evolutions.first.form
      else
        case @config.multiple_evolutions_choice_mode
        when :first
          selected_evolution = evolutions.first
        when :last
          selected_evolution = evolutions.last
        else # :random
          selected_evolution = evolutions.sample
        end
        log_debug("Multiple valid evolutions found. Evolved species #{@species} to #{selected_evolution.db_symbol}.")
        @species = selected_evolution.db_symbol
        @form = selected_evolution.form
      end

      autoscale_evolution_up if index_in_evo_line == 0
    end

    # Change the Pokémon species for one of it's pre-evolutions if its level is low enough
    def autoscale_evolution_down
      log_debug("Starting evolution autoscaling down for species #{@species}.")
      data = data_creature_form(@species, @form)
      baby_symbol = data.baby_db_symbol
      if baby_symbol.nil? || @species == baby_symbol
        log_debug('No pre-evolutions found. Stopping evolution autoscaling down.')
        return
      end

      baby_evolutions = data_creature_form(baby_symbol, data.baby_form).evolutions
      if baby_evolutions.any? { |evo| evo.db_symbol == @species && evo.form == @form }
        evolutions = baby_evolutions.select { |evo| evo.db_symbol == @species && evo.form == @form }
        if evolutions.none? { |evo| check_evolution_validity(evo, 0) }
          log_debug("De-evolved species #{@species} to #{baby_symbol}.")
          @species = baby_symbol
          @form = data.baby_form
          return
        end
      end

      baby_evolutions.each do |evo|
        evo_data = data_creature_form(evo.db_symbol, evo.form)
        evolutions = evo_data.evolutions.select { |evo| evo.db_symbol == @species && evo.form == @form }
        next if evolutions.empty?
        next unless evolutions.none? { |evo| check_evolution_validity(evo, 1) }

        log_debug("De-evolved species #{@species} to #{evo.db_symbol}.")
        @species = evo.db_symbol
        @form = evo.form
        autoscale_evolution_down
        break
      end
    end

    # Check if the evolution is valid based on the current level and conditions
    # @param evolution [PFM::Creature::Evolution] evolution to check
    # @param index [Integer] index in the evolution line
    # @return [Boolean] whether the evolution is valid
    def check_evolution_validity(evolution, index)
      if @config.custom_evolution_checks.any? { |check| check[0] == @species.to_s }
        log_debug('Using custom evolution check.')
        return @config.custom_evolution_checks.any? { |check| check[0] == @species.to_s && check[1] <= @level }
      end

      return false if UNSUPPORTED_EVOLUTION_METHODS.any? { |cond| !evolution.condition_data(cond).nil? }

      return false if (!evolution.condition_data(:minLevel).nil? && evolution.condition_data(:minLevel) > @level) ||
                      (!evolution.condition_data(:maxLevel).nil? && evolution.condition_data(:maxLevel) < @level) ||
                      (!evolution.condition_data(:gender).nil? && evolution.condition_data(:gender) != (extra[:gender] || -1)) ||
                      (!evolution.condition_data(:tradeWith).nil? && @config.evolution_levels_for_specific_methods[:trade][index] > @level) ||
                      (!evolution.condition_data(:minLoyalty).nil? && @config.evolution_levels_for_specific_methods[:loyalty][index] > @level) ||
                      (!evolution.condition_data(:maxLoyalty).nil? && @config.evolution_levels_for_specific_methods[:loyalty][index] < @level)

      return false if (!evolution.condition_data(:skill1) ||
                      !evolution.condition_data(:skill2) ||
                      !evolution.condition_data(:skill3) ||
                      !evolution.condition_data(:skill4)) &&
                      @config.evolution_levels_for_specific_methods[:skill][index] > @level

      return false if CONFIGURED_EVOLUTION_METHODS.any? do |cond|
        !evolution.condition_data(cond).nil? && @config.evolution_levels_for_specific_methods[cond][index] > @level
      end

      return true
    end
  end
end
