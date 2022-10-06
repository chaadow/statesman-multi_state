# frozen_string_literal: true

require 'statesman/adapters/custom_active_record_queries'

module Statesman
  module MultiState
    module ActiveRecordMacro
      extend ActiveSupport::Concern

      class_methods do
        def has_one_state_machine(field_name, state_machine_klass:, transition_klass:, transition_name: transition_klass.to_s.underscore.pluralize.to_sym)
          state_machine_name = "#{field_name}_state_machine"
          virtual_attribute_name = "#{field_name}_state_form"

          # To handle STI, this needs to be done to get the base klass
          base_klass = caller_locations.first.label.split(':').last[...-1]

          has_many transition_name, class_name: transition_klass.to_s, autosave: false, dependent: :destroy

          include Statesman::Adapters::CustomActiveRecordQueries[
            transition_class: transition_klass.constantize,
            initial_state: state_machine_klass.constantize.send(:initial_state),
            transition_name: transition_name,
            most_recent_transition_alias: "#{field_name}_alias",
            field_name: field_name
          ]

          attribute virtual_attribute_name

          %w[current_state in_state? transition_to transition_to! can_transition_to? history last_transition
             last_transition_to].each do |meth|
            delegate meth, to: state_machine_name, prefix: field_name
          end

          generated_association_methods.class_eval <<~CODE, __FILE__, __LINE__ + 1

            def #{state_machine_name}
              key = "@#{state_machine_name}"
              return instance_variable_get(key) if instance_variable_defined?(key)

              instance_variable_set(key, #{state_machine_klass}.new(
                self,
                transition_class: #{transition_klass},
                association_name: "#{transition_name}"
              ))
            end

            def #{virtual_attribute_name}
              super() || #{field_name}_current_state
            end

            def #{field_name}_current_state_human
              Hash[self.class.#{field_name}_human_wrapper]
                .invert[#{field_name}_current_state]
            end
          CODE

          include(const_set("#{field_name}#{SecureRandom.hex(4)}_mod".classify, Module.new).tap do |mod|
            mod.module_eval do
              extend ActiveSupport::Concern

              class_methods do
                define_method :"#{field_name}_human_wrapper" do
                  key = "@#{field_name}_human_wrapper"
                  return instance_variable_get(key) if instance_variable_defined?(key)

                  instance_variable_set(key, state_machine_klass.constantize.send(:states).map do |s|
                                               [I18n.t(s, scope: "statesman.#{field_name}_#{base_klass.underscore}"), s]
                                             end)
                end
              end

              class_eval <<~METHOD, __FILE__, __LINE__ + 1
                def save_with_state(**options)
                  @registered_callbacks ||= []
                  if #{virtual_attribute_name}_changed? && #{field_name}_can_transition_to?(#{virtual_attribute_name})
                    @registered_callbacks << -> { #{field_name}_transition_to(#{virtual_attribute_name}, **options) }
                  end

                  if defined?(super)
                    super
                  else
                    save
                    @registered_callbacks.each(&:call)
                    @registered_callbacks = []
                  end
                end
              METHOD
            end
          end)

          reflection = ActiveRecord::Reflection.create(
            :has_one_state_machine,
            field_name,
            nil,
            { state_machine_klass: state_machine_klass, transition_klass: transition_klass,
              transition_name: transition_name },
            self
          )

          yield reflection if block_given?

          ActiveRecord::Reflection.add_state_machine_reflection(self, field_name, reflection)
        end
      end
    end
  end
end
