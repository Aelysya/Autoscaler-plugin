module Battle
  class Logic
    module AutoscalerPlugin
      private

      # Load the battlers from a party
      # @param party [Array<PFM::Pokemon>]
      # @param bank [Integer]
      # @param index [Integer] index of the party in the parties array (party_id)
      def load_battlers_from_party(party, bank, index)
        super

        return unless $game_switches[Configs.autoscaler.global_activation_switch]
        return if bank == 0 && index == 0 # Do not scale the player's party
        return if bank == 0 && !$game_switches[Configs.autoscaler.allow_allies_scaling_switch] # Do not scale allies if not allowed
        return if bank == 1 && !@scene.battle_info.trainer_battle? && !$game_switches[Configs.autoscaler.allow_wild_scaling_switch] # Do not scale wild Creatures if not allowed

        battlers = (@battlers[bank] ||= [])
        battlers.select { |battler| battler.party_id == index }.each(&:autoscale)
      end
    end
    prepend AutoscalerPlugin
  end
end
