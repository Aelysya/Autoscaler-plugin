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
        return if bank == 0 && index == 0
        # return if bank == 0 && !Yuki::Config::Autoscaler::SCALE_ALLIES

        battlers = (@battlers[bank] ||= [])
        battlers.select { |battler| battler.party_id == index }.each(&:autoscale)
      end
    end
    prepend AutoscalerPlugin
  end
end
