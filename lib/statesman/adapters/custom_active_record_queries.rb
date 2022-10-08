# frozen_string_literal: true

module Statesman
  module Adapters
    module CustomActiveRecordQueries

      def self.[](**args)
        ClassMethods.new(**args)
      end

      class ClassMethods < Module

        def initialize(**args)
          @args = args
        end

        def included(base)
          ensure_inheritance(base)

          field_name = @args.delete(:field_name)

          query_builder = ::Statesman::Adapters::ActiveRecordQueries::QueryBuilder.new(base, **@args)

          join_name = :"#{field_name}_most_recent_transition_join"

          base.define_singleton_method(join_name) do
            query_builder.most_recent_transition_join
          end

          define_in_state(base, query_builder, join_name, field_name)
          define_not_in_state(base, query_builder, join_name, field_name)
        end

        private

        def ensure_inheritance(base)
          klass = self
          existing_inherited = base.method(:inherited)
          base.define_singleton_method(:inherited) do |subclass|
            existing_inherited.call(subclass)
            subclass.send(:include, klass)
          end
        end

        def define_in_state(base, query_builder, join_name, field_name)
          base.define_singleton_method(:"#{field_name}_in_state") do |*states|
            states = states.flatten

            joins(public_send(join_name)).
              where(query_builder.states_where(states), states)
          end
        end

        def define_not_in_state(base, query_builder, join_name, field_name)
          base.define_singleton_method(:"#{field_name}_not_in_state") do |*states|
            states = states.flatten

            joins(public_send(join_name)).
              where.not(query_builder.states_where(states), states)
          end
        end
      end
    end
  end
end
