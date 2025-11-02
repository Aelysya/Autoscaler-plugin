module Configs
  KEY_TRANSLATIONS[:globalActivationSwitch] = :global_activation_switch
  KEY_TRANSLATIONS[:allowLevelScalingDownSwitch] = :allow_level_scaling_down_switch
  KEY_TRANSLATIONS[:allowEvolutionScalingSwitch] = :allow_evolution_scaling_switch
  KEY_TRANSLATIONS[:allowEvolutionScalingDownSwitch] = :allow_evolution_scaling_down_switch
  KEY_TRANSLATIONS[:allowMovesetScalingSwitch] = :allow_moveset_scaling_switch
  KEY_TRANSLATIONS[:allowMovesetScalingDownSwitch] = :allow_moveset_scaling_down_switch
  KEY_TRANSLATIONS[:allowTrainersScalingSwitch] = :allow_trainers_scaling_switch
  KEY_TRANSLATIONS[:allowAllyTrainersScalingSwitch] = :allow_ally_trainers_scaling_switch
  KEY_TRANSLATIONS[:allowWildBattlesScalingSwitch] = :allow_wild_battles_scaling_switch
  KEY_TRANSLATIONS[:allowQuestRewardsScalingSwitch] = :allow_quest_rewards_scaling_switch
  KEY_TRANSLATIONS[:allowNonLevelUpMovesReplacingSwitch] = :allow_non_level_up_moves_replacing_switch
  KEY_TRANSLATIONS[:allowDifferentTypeMovesReplacingSwitch] = :allow_different_type_moves_replacing_switch
  KEY_TRANSLATIONS[:allowStatusMovesReplacingSwitch] = :allow_status_moves_replacing_switch
  KEY_TRANSLATIONS[:scalingModeVariable] = :scaling_mode_variable
  KEY_TRANSLATIONS[:maximumLevelsToScaleVariable] = :maximum_levels_to_scale_variable
  KEY_TRANSLATIONS[:manualTargetLevelVariable] = :manual_target_level_variable
  KEY_TRANSLATIONS[:flatLevelModifierVariable] = :flat_level_modifier_variable
  KEY_TRANSLATIONS[:multipleEvolutionsChoiceMode] = :multiple_evolutions_choice_mode
  KEY_TRANSLATIONS[:evolutionLevelsForSpecificMethods] = :evolution_levels_for_specific_methods
  KEY_TRANSLATIONS[:customEvolutionChecks] = :custom_evolution_checks

  module Project
    class Autoscaler
      # Global activation switch ID
      # @return [Integer]
      attr_accessor :global_activation_switch

      # Allow level scaling down switch ID
      # @return [Integer]
      attr_accessor :allow_level_scaling_down_switch

      # Allow evolution scaling switch ID
      # @return [Integer]
      attr_accessor :allow_evolution_scaling_switch

      # Allow evolution scaling down switch ID
      # @return [Integer]
      attr_accessor :allow_evolution_scaling_down_switch

      # Allow moveset scaling switch ID
      # @return [Integer]
      attr_accessor :allow_moveset_scaling_switch

      # Allow moveset scaling down switch ID
      # @return [Integer]
      attr_accessor :allow_moveset_scaling_down_switch

      # Allow trainers scaling switch ID
      # @return [Integer]
      attr_accessor :allow_trainers_scaling_switch

      # Allow ally trainers scaling switch ID
      # @return [Integer]
      attr_accessor :allow_ally_trainers_scaling_switch

      # Allow wild battles scaling switch ID
      # @return [Integer]
      attr_accessor :allow_wild_battles_scaling_switch

      # Allow quest rewards scaling switch ID
      # @return [Integer]
      attr_accessor :allow_quest_rewards_scaling_switch

      # Allow non-level-up moves replacing switch ID
      # @return [Integer]
      attr_accessor :allow_non_level_up_moves_replacing_switch

      # Allow different type moves replacing switch ID
      # @return [Integer]
      attr_accessor :allow_different_type_moves_replacing_switch

      # Allow status moves replacing switch ID
      # @return [Integer]
      attr_accessor :allow_status_moves_replacing_switch

      # Scaling mode variable ID
      # @return [Integer]
      attr_accessor :scaling_mode_variable

      # Maximum levels to scale variable ID
      # @return [Integer]
      attr_accessor :maximum_levels_to_scale_variable

      # Manual target level variable ID
      # @return [Integer]
      attr_accessor :manual_target_level_variable

      # Flat level modifier variable ID
      # @return [Integer]
      attr_accessor :flat_level_modifier_variable

      # Multiple evolutions choice mode (:random, :first, :last)
      # @return [Symbol]
      attr_accessor :multiple_evolutions_choice_mode

      # Evolution levels for specific methods
      # @return [Array<Integer>]
      attr_accessor :evolution_levels_for_specific_methods

      # Custom evolution checks
      # @return [Array<Array>]
      attr_accessor :custom_evolution_checks
    end
  end

  # @!method self.autoscaler
  # @return [Project::Autoscaler]
  register(:autoscaler, 'autoscaler_config', :json, false, Project::Autoscaler)
end
