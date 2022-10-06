# frozen_string_literal: true

require 'test_helper'

module Statesman
  module MultiState
    class ActiveRecordMacroTest < ActiveSupport::TestCase
      setup do
        @klass = build_ar_klass
        setup_state_machines_for(klass: @klass)
      end

      test '.has_one_state_machine define a has_many association for the transition class for each state machine' do
        statuses.each do |status|
          assert_equal ActiveRecord::Reflection::HasManyReflection,
                       @klass.reflect_on_association(:"#{status}_order_transitions").class
        end
      end

      test '.has_one_state_machine defines a virtual attribute for each state machine' do
        statuses.each do |status|
          assert @klass.new.respond_to?(:"#{status}_state_form")
        end
      end

      test '.has_one_state_machine defines active record scopes for each state machine' do
        statuses.each do |status|
          assert @klass.respond_to?(:"#{status}_in_state")
        end
      end

      test '.has_one_state_machine delegate statesman methods to the state machine klass for each state machine' do
        statuses.each do |status|
          delegated_methods.each do |meth|
            assert @klass.new.respond_to?(:"#{status}_#{meth}")
          end
        end
      end

      test '.has_one_state_machine defines i18n instance methods for each state machine' do
        order = Order.new

        # Check test/dummy/config/en.yml for translations
        statuses.each do |status|
          # order.user_status_current_state_human
          assert_equal I18n.t(order.public_send("#{status}_current_state"), scope: "statesman.#{status}_order"),
                       order.public_send("#{status}_current_state_human")

          # Ex. Order.user_status_human_wrapper
          assert_equal(
            state_machine_klass_for(klass: Order, state_machine: status)
            .public_send(:states).map { |s| [I18n.t(s, scope: "statesman.#{status}_order"), s] },
            Order.send("#{status}_human_wrapper")
          )
        end
      end

      test 'defines "#save_with_state" to handle state on creation' do
        order = Order.new
        assert_equal :user_pending, order.user_status_current_state.to_sym
        assert_equal :admin_pending, order.admin_status_current_state.to_sym
        assert_equal 0, UserStatusOrderTransition.count
        assert_equal 0, AdminStatusOrderTransition.count

        order.user_status_state_form = 'processed'
        order.admin_status_state_form = 'validated'

        order.save_with_state

        assert_equal :processed, order.user_status_current_state.to_sym
        assert_equal :validated, order.admin_status_current_state.to_sym
        assert_equal 1, UserStatusOrderTransition.count
        assert_equal 1, AdminStatusOrderTransition.count
      end

      test 'sets an Reflection::HasOneStateMachineReflection and yield it to a block if given' do
        result = nil
        klass = build_ar_klass

        klass.has_one_state_machine :user_status, state_machine_klass: 'UserStatusOrderStateMachine',
                                                  transition_klass: 'UserStatusOrderTransition' do |reflection|
          result = reflection
        end

        assert_equal Statesman::MultiState::Reflection::HasOneStateMachineReflection, result.class
      end

      test 'adds the new states to the state_machine_reflections array' do
        klass = build_ar_klass

        assert_empty klass.state_machine_reflections

        assert_difference 'klass.state_machine_reflections.size', +2 do
          setup_state_machines_for(klass: klass)

          assert_equal statuses, klass.reflect_on_all_state_machines.map(&:name)
        end
      end

      private

      def statuses
        %i[user_status admin_status]
      end

      def delegated_methods
        %i[current_state in_state? transition_to transition_to! can_transition_to? history last_transition
           last_transition_to]
      end

      def setup_state_machines_for(klass:)
        klass.has_one_state_machine :user_status, state_machine_klass: 'UserStatusOrderStateMachine',
                                                  transition_klass: 'UserStatusOrderTransition'
        klass.has_one_state_machine :admin_status, state_machine_klass: 'AdminStatusOrderStateMachine',
                                                   transition_klass: 'AdminStatusOrderTransition'
      end

      def build_ar_klass
        Class.new(ApplicationRecord) do
          self.table_name = 'orders'
        end
      end

      def state_machine_klass_for(klass:, state_machine:)
        klass.reflect_on_state_machine(state_machine).options[:state_machine_klass].constantize
      end
    end
  end
end
