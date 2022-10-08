# frozen_string_literal: true

module Statesman
  module MultiState
    module Reflection
      # Holds all the metadata about a  state_machine as it was
      # specified in the Active Record class.
      class HasOneStateMachineReflection < ::ActiveRecord::Reflection::MacroReflection # :nodoc:
        def macro
          :has_one_state_machine
        end
      end

      module ReflectionExtension
        def add_state_machine_reflection(model, name, reflection)
          model.state_machine_reflections = model.state_machine_reflections.merge(name.to_s => reflection)
        end

        private

        def reflection_class_for(macro)
          case macro
          when :has_one_state_machine
            HasOneStateMachineReflection
          else
            super
          end
        end
      end

      module ActiveRecordExtensions
        extend ActiveSupport::Concern

        included do
          class_attribute :state_machine_reflections, instance_writer: false, default: {}
        end

        class_methods do
          # Returns an array of reflection objects for all the state
          # machines in the class.
          def reflect_on_all_state_machines
            state_machine_reflections.values
          end

          # Returns the reflection object for the named +state_machine+.
          #
          #    User.reflect_on_state_machine(:status)
          #    # => the status reflection
          #
          def reflect_on_state_machine(state_machine)
            state_machine_reflections[state_machine.to_s]
          end
        end
      end
    end
  end
end
