# frozen_string_literal: true

require 'statesman'
require 'statesman/adapters/custom_active_record_queries'

module Statesman
  module MultiState
    module ActiveRecordMacro
      extend ActiveSupport::Concern

      class_methods do
        def has_one_state_machine(field_name, state_machine_klass:, transition_klass:,
                                  transition_name: transition_klass.to_s.demodulize.underscore.pluralize.to_sym, virtual_attribute_name: "#{field_name}_state_form",
                                  transition_foreign_key: nil, initial_transition: true)
          state_machine_name = "#{field_name}_state_machine"

          # To handle STI, this needs to be done to get the base klass
          base_klass = caller_locations.first.label.split(':').last[...-1]

          association_options = { class_name: transition_klass.to_s, autosave: false, dependent: :destroy }.merge(transition_foreign_key ? { foreign_key: transition_foreign_key.to_s } : {} )
          has_many transition_name, **association_options

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
              return instance_variable_get(key) if instance_variable_defined?(key) && @#{state_machine_name}.object.persisted?

              instance_variable_set(key, #{state_machine_klass}.new(
                self,
                transition_class: #{transition_klass},
                association_name: "#{transition_name}",
                initial_transition: false
              ))

              if #{initial_transition}
                if @#{state_machine_name}.history.empty? && #{state_machine_klass}.initial_state
                  if @#{state_machine_name}.object.persisted? && self.class.current_role != ::ActiveRecord.reading_role
                    @#{state_machine_name}.instance_variable_get(:@storage_adapter).create(nil, #{state_machine_klass}.initial_state)
                  end
                end
              end
              @#{state_machine_name}
            end

            def #{virtual_attribute_name}
              value = read_attribute("#{virtual_attribute_name}")
              value.nil? ? #{field_name}_current_state : value
            end

            def #{field_name}_current_state_human
              Hash[self.class.#{field_name}_human_wrapper]
                .invert[#{field_name}_current_state]
            end
          CODE

          # Define a public reader so form helpers, serializers, and other
          # callers that use `public_send(field_name)` work. Guard against
          # clobbering an existing column reader or user-defined method with
          # the same name as `field_name`.
          table_name_available = name.present? || (instance_variable_defined?(:@table_name) && @table_name.present?)
          has_column_reader = if respond_to?(:column_names) && table_name_available &&
                                 respond_to?(:table_exists?) && table_exists?
                                column_names.include?(field_name.to_s)
                              else
                                false
                              end

          unless method_defined?(field_name) || private_method_defined?(field_name) || has_column_reader
            generated_association_methods.class_eval <<~READER, __FILE__, __LINE__ + 1
              def #{field_name}
                #{field_name}_current_state
              end
            READER
          end

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
                  if #{virtual_attribute_name}.to_s != #{field_name}_current_state.to_s
                    if #{field_name}_can_transition_to?(#{virtual_attribute_name})
                      @registered_callbacks << -> { #{field_name}_transition_to(#{virtual_attribute_name}, **options) }
                    else
                      errors.add(
                        :#{field_name},
                        :invalid_transition,
                        current_state: #{field_name}_current_state_human,
                        target_state: I18n.t(#{virtual_attribute_name}, scope: "statesman.#{field_name}_#{base_klass.underscore}", default: #{virtual_attribute_name}.to_s)
                      )
                      return false
                    end
                  end

                  if defined?(super)
                    super
                  else
                    save.tap do
                      @registered_callbacks.each(&:call)
                      @registered_callbacks = []
                    end
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
              transition_name: transition_name, virtual_attribute_name: virtual_attribute_name,
              transition_foreign_key: transition_foreign_key, initial_transition: initial_transition },
            self
          )

          yield reflection if block_given?

          ActiveRecord::Reflection.add_state_machine_reflection(self, field_name, reflection)
        end
      end
    end
  end
end
