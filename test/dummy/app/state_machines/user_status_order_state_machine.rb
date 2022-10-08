# frozen_string_literal: true

class UserStatusOrderStateMachine
  include Statesman::Machine

  state :user_pending, initial: true
  state :processed

  transition from: :user_pending, to: :processed
end
