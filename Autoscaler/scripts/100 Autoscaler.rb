module Autoscaler
  # The encounter to autoscale
  attr_reader :encounter

  # The context of the autoscaling (:trainer, :ally, :wild, :quest)
  attr_reader :context

  # Initialize a new Autoscaler instance
  # @param encounter [PFM::Group::Encounter] encounter to autoscale
  # @param context [Symbol] context of the autoscaling (:trainer, :ally, :wild, :quest)
  def initialize(encounter, context)
    @encounter = encounter
    @context = context
  end

  def autoscale
    
  end
end
