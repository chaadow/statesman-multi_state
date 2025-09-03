# frozen_string_literal: true

require 'test_helper'

module Statesman
  module MultiState
    class ReflectionTest < ActiveSupport::TestCase
      test 'reflecting on a singular state machine' do
        reflection = Order.reflect_on_state_machine(:user_status)

        assert_equal Order, reflection.active_record
        assert_equal :user_status, reflection.name
        assert_equal :has_one_state_machine, reflection.macro
        assert_equal 'UserStatusOrderStateMachine', reflection.options[:state_machine_klass]
        assert_equal 'UserStatusOrderTransition', reflection.options[:transition_klass]
        assert reflection.options[:initial_transition]

        reflection = Order.reflect_on_state_machine(:custom_status)
        assert_equal :transitions, reflection.options[:transition_name]
        assert_equal 'my_attribute', reflection.options[:virtual_attribute_name]
        assert_equal false, reflection.options[:initial_transition]

        reflection = Order.reflect_on_state_machine(:foreign_key_status)
        assert_equal 'custom_fk_id', reflection.options[:transition_foreign_key]
      end

      test 'reflection on a singular state machine with the same name as a state machine on another model' do
        klass = Class.new(ApplicationRecord) do
          has_one_state_machine :user_status, state_machine_klass: 'UserStatusOrderStateMachine',
                                              transition_klass: 'UserStatusOrderTransition'
        end

        reflection = klass.reflect_on_state_machine(:user_status)

        assert_equal klass, reflection.active_record
      end

      test 'reflecting on all state machines' do
        reflections = Order.reflect_on_all_state_machines.sort_by(&:name)

        assert_equal [Order], reflections.collect(&:active_record).uniq
        assert_equal %i[admin_status custom_status foreign_key_status user_status], reflections.collect(&:name)
        assert_equal %i[has_one_state_machine has_one_state_machine has_one_state_machine has_one_state_machine], reflections.collect(&:macro)
        assert_equal %i[admin_status_order_transitions transitions foreign_key_status_order_transitions user_status_order_transitions], reflections.collect { |reflection|
                                                                                                     reflection.options[:transition_name]
                                                                                                   }
      end
    end
  end
end
