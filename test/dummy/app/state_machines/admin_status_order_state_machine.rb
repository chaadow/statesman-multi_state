# frozen_string_literal: true

class AdminStatusOrderStateMachine
  include Statesman::Machine

  state :admin_pending, initial: true
  state :validated

  transition from: :admin_pending, to: :validated
end
