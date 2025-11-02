class Game_Temp
  # Current autoscaling context (trainer, ally, wild, quest, egg)
  # @return [Symbol]
  attr_accessor :autoscaling_context

  module AutoscalerPlugin
    def initialize
      @autoscaling_context = :none
      super
    end
  end
  prepend AutoscalerPlugin
end

module PFM
  class Quests
    class Quest
      class << self
        module AutoscalerPlugin
          # Get Pokémon from data
          # @param data [Integer, Symbol, Hash, Studio::Group::Encounter] data of the Pokémon to give
          # @param level [Integer] The level of the Pokémon (only used if the data is an Integer or a Symbol)
          def pokemon_from_data(data, level)
            $game_temp.autoscaling_context = :quest unless $game_temp.autoscaling_context == :egg
            super
          end
        end
        prepend AutoscalerPlugin
      end

      module AutoscalerPlugin
        private

        # Earning an egg from a quest
        # @param data [Integer, Symbol, Hash, Studio::Group::Encounter] data of the egg to give
        def earning_egg(data)
          $game_temp.autoscaling_context = :egg
          super
        end
      end
      prepend AutoscalerPlugin
    end
  end

  class Wild_Battle
    module AutoscalerPlugin
      # Set the Battle::Info with the right information
      # @param battle_id [Integer] ID of the events to load for battle scenario
      # @return [Battle::Logic::BattleInfo, nil]
      def setup(battle_id = 1)
        $game_temp.autoscaling_context = :wild
        super
      end

      # Configure the ally trainer for the Wild Battle if an ally is specified
      # @param bi [Battle::Logic::BattleInfo]
      # @param allied_trainer_id [Integer]
      def add_ally_trainer(bi, allied_trainer_id)
        $game_temp.autoscaling_context = :ally
        super
      end
    end
    prepend AutoscalerPlugin
  end
end

module Battle
  class Logic
    class BattleInfo
      class << self
        module AutoscalerPlugin
          # Add a trainer to the battle_info object
          # @param battle_info [BattleInfo]
          # @param bank [Integer] bank of the trainer
          # @param id_trainer [Integer] ID of the trainer in the database
          def add_trainer(battle_info, bank, id_trainer)
            $game_temp.autoscaling_context = bank == 0 ? :ally : :trainer
            super
          end
        end
        prepend AutoscalerPlugin
      end
    end
  end
end
