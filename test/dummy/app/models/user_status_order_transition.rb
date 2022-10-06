# frozen_string_literal: true

class UserStatusOrderTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  belongs_to :order, inverse_of: :user_status_order_transitions

  after_destroy :update_most_recent, if: :most_recent?

  private

  def update_most_recent
    last_transition = order.user_status_order_transitions.order(:sort_key).last
    return unless last_transition.present?

    last_transition.update_column(:most_recent, true)
  end
end
