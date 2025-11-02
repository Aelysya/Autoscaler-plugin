module PFM
  class Autoscaler
    # The level of the encounter
    # @return [Integer]
    attr_reader :level

    # The species of the encounter
    # @return [Symbol]
    attr_reader :species

    # The form of the encounter
    # @return [Integer]
    attr_reader :form

    # The moveset of the encounter
    # @return [Array<Symbol>]
    attr_reader :moves

    # The extra setup information of the encounter
    # @return [Hash]
    attr_reader :extra

    # The context of the autoscaling (:trainer, :ally, :wild, :quest)
    # @return [Symbol]
    attr_reader :context

    # The autoscaler configuration
    # @return [Config::Project::Autoscaler]
    attr_reader :config

    # The reference level to autoscale towards
    # @return [Integer]
    attr_reader :reference_level

    # Initialize a new Autoscaler instance
    # @param encounter [PFM::Group::Encounter] encounter to autoscale
    # @param context [Symbol] context of the autoscaling (:trainer, :ally, :wild, :quest)
    def initialize(encounter, context)
      @level = rand(encounter.level_setup.range)
      @species = encounter.specie
      @form = encounter.generic_form_generation
      @moves = encounter.extra[:moves] || %i[__undef__ __undef__ __undef__ __undef__]
      @extra = encounter.extra

      @context = context
      @config = Configs.autoscaler
      @reference_level = -1

      log_debug("Initialized autoscaler in :#{@context} context.")
      log_encounter_state('Encounter state before autoscaling:')
    end

    # Autoscale the encounter according to the configuration
    # @return [PFM::Pokemon] autoscaled creature
    def autoscale
      unless calc_reference_level
        log_error('Invalid scaling reference, check the configuration. Stopping autoscale.')
        return @level, @species, @form, @moves
      end

      autoscale_direction = autoscale_level
      log_encounter_state('Encounter state after level autoscaling:') unless autoscale_direction == :none

      case autoscale_direction
      when :up
        if $game_switches[@config.allow_evolution_scaling_switch]
          autoscale_evolution_up
          log_encounter_state('Encounter state after evolution autoscaling:')
        end
        if $game_switches[@config.allow_moveset_scaling_switch]
          autoscale_moveset
          log_encounter_state('Encounter state after moveset autoscaling:')
        end
      when :down
        if $game_switches[@config.allow_evolution_scaling_down_switch]
          autoscale_evolution_down
          log_encounter_state('Encounter state after evolution autoscaling down:')
        end
        if $game_switches[@config.allow_moveset_scaling_down_switch]
          autoscale_moveset
          log_encounter_state('Encounter state after moveset autoscaling down:')
        end
      end

      log_encounter_state('Encounter state after full autoscaling:')
      return @level, @species, @form, @moves
    end

    private

    # Log the encounter state for debugging
    # @param message [String] message to log
    def log_encounter_state(message)
      log_debug("#{message} Level: #{@level}, Species: :#{@species} (Form: #{@form}), Moves: #{@moves.inspect}")
    end
  end
end
