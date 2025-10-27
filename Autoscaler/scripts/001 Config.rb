module Configs
  KEY_TRANSLATIONS[:globalActivationSwitch] = :global_activation_switch
  KEY_TRANSLATIONS[:allowScaleDownSwitch] = :allow_scale_down_switch
  KEY_TRANSLATIONS[:allowEvolutionScalingSwitch] = :allow_evolution_scaling_switch
  KEY_TRANSLATIONS[:allowMovesetScalingSwitch] = :allow_moveset_scaling_switch
  KEY_TRANSLATIONS[:allowAlliesScalingSwitch] = :allow_allies_scaling_switch
  KEY_TRANSLATIONS[:allowWildScalingSwitch] = :allow_wild_scaling_switch
  KEY_TRANSLATIONS[:maximumLevelsToScaleVariable] = :maximum_levels_to_scale_variable
  KEY_TRANSLATIONS[:manualTargetLevelVariable] = :manual_target_level_variable
  KEY_TRANSLATIONS[:difficultySettings] = :difficulty_settings
  KEY_TRANSLATIONS[:label] = :label
  KEY_TRANSLATIONS[:scalingReference] = :scaling_reference

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

      # Allow allies scaling switch ID
      # @return [Integer]
      attr_accessor :allow_allies_scaling_switch

      # Allow wild scaling switch ID
      # @return [Integer]
      attr_accessor :allow_wild_scaling_switch

      # Maximum levels to scale variable ID
      # @return [Integer]
      attr_accessor :maximum_levels_to_scale_variable

      # Manual target level variable ID
      # @return [Integer]
      attr_accessor :manual_target_level_variable

      # Difficulty settings
      # @return [Array<Hash>]
      attr_accessor :difficulty_settings
    end
  end

  # @!method self.autoscaler
  # @return [Project::Autoscaler]
  register(:autoscaler, 'autoscaler_config', :json, false, Project::Autoscaler)
end
