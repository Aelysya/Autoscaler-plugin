module Configs
  KEY_TRANSLATIONS[:globalActivationSwitch] = :global_activation_switch
  KEY_TRANSLATIONS[:allowScaleDownSwitch] = :allow_scale_down_switch
  KEY_TRANSLATIONS[:allowEvolutionScalingSwitch] = :allow_evolution_scaling_switch
  KEY_TRANSLATIONS[:allowEvolutionScalingDownSwitch] = :allow_evolution_scaling_down_switch
  KEY_TRANSLATIONS[:allowMovesetScalingSwitch] = :allow_moveset_scaling_switch
  KEY_TRANSLATIONS[:allowNonLevelUpMovesReplacingSwitch] = :allow_non_level_up_moves_replacing_switch
  KEY_TRANSLATIONS[:allowDifferentTypeMovesReplacingSwitch] = :allow_different_type_moves_replacing_switch
  KEY_TRANSLATIONS[:allowStatusMovesReplacingSwitch] = :allow_status_moves_replacing_switch
  KEY_TRANSLATIONS[:allowAlliesScalingSwitch] = :allow_allies_scaling_switch
  KEY_TRANSLATIONS[:allowWildScalingSwitch] = :allow_wild_scaling_switch
  KEY_TRANSLATIONS[:allowQuestsRewardScalingSwitch] = :allow_quests_reward_scaling_switch
  KEY_TRANSLATIONS[:currentDifficultySettingVariable] = :current_difficulty_setting_variable
  KEY_TRANSLATIONS[:maximumLevelsToScaleVariable] = :maximum_levels_to_scale_variable
  KEY_TRANSLATIONS[:manualTargetLevelVariable] = :manual_target_level_variable
  KEY_TRANSLATIONS[:loyaltyEvolutionsLevels] = :loyalty_evolution_levels
  KEY_TRANSLATIONS[:stoneEvolutionsLevels] = :stone_evolution_levels
  KEY_TRANSLATIONS[:tradeEvolutionsLevels] = :trade_evolution_levels
  KEY_TRANSLATIONS[:heldItemEvolutionsLevels] = :held_item_evolution_levels
  KEY_TRANSLATIONS[:scalingModeVariable] = :scaling_mode_variable
  KEY_TRANSLATIONS[:flatLevelModifierVariable] = :flat_level_modifier_variable

  module Project
    class Autoscaler
      # Global activation switch ID
      # @return [Integer]
      attr_accessor :global_activation_switch

      # Allow scale down switch ID
      # @return [Integer]
      attr_accessor :allow_scale_down_switch

      # Allow evolution scaling switch ID
      # @return [Integer]
      attr_accessor :allow_evolution_scaling_switch

      # Allow moveset scaling switch ID
      # @return [Integer]
      attr_accessor :allow_moveset_scaling_switch

      # Allow non-level-up moves replacing switch ID
      # @return [Integer]
      attr_accessor :allow_non_level_up_moves_replacing_switch

      # Allow different type moves replacing switch ID
      # @return [Integer]
      attr_accessor :allow_different_type_moves_replacing_switch

      # Allow status moves replacing switch ID
      # @return [Integer]
      attr_accessor :allow_status_moves_replacing_switch

      # Allow allies scaling switch ID
      # @return [Integer]
      attr_accessor :allow_allies_scaling_switch

      # Allow wild scaling switch ID
      # @return [Integer]
      attr_accessor :allow_wild_scaling_switch

      # Allow quests reward scaling switch ID
      # @return [Integer]
      attr_accessor :allow_quests_reward_scaling_switch

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

      # Loyalty evolutions levels
      # @return [Array<Integer>]
      attr_accessor :loyalty_evolution_levels

      # Stone evolutions levels
      # @return [Array<Integer>]
      attr_accessor :stone_evolution_levels

      # Trade evolutions levels
      # @return [Array<Integer>]
      attr_accessor :trade_evolution_levels

      # Held item evolutions levels
      # @return [Array<Integer>]
      attr_accessor :held_item_evolution_levels
    end
  end

  # @!method self.autoscaler
  # @return [Project::Autoscaler]
  register(:autoscaler, 'autoscaler_config', :json, false, Project::Autoscaler)
end
