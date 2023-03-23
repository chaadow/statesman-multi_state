# frozen_string_literal: true

class Order < ApplicationRecord
  has_one_state_machine :user_status, state_machine_klass: 'UserStatusOrderStateMachine',
                                      transition_klass: 'UserStatusOrderTransition'
  has_one_state_machine :admin_status, state_machine_klass: 'AdminStatusOrderStateMachine',
                                       transition_klass: 'AdminStatusOrderTransition'
  has_one_state_machine :custom_status, state_machine_klass: 'AdminStatusOrderStateMachine',
                                        transition_klass: 'AdminStatusOrderTransition', transition_name: :transitions, virtual_attribute_name: 'my_attribute'
end
