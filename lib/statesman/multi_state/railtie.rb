# frozen_string_literal: true

module Statesman
  module MultiState
    class Railtie < ::Rails::Railtie
      initializer 'statesman.multi_state.init' do
        require 'statesman/multi_state/reflection'
        require 'statesman/multi_state/active_record_macro'

        ActiveSupport.on_load(:active_record) do
          include Statesman::MultiState::ActiveRecordMacro
          include Statesman::MultiState::Reflection::ActiveRecordExtensions

          ActiveRecord::Reflection.singleton_class.prepend(Statesman::MultiState::Reflection::ReflectionExtension)
        end
      end

      initializer 'statesman.multi_state.i18n' do |app|
        app.config.i18n.load_path += Dir[File.expand_path('locales/*.yml', __dir__)]
      end
    end
  end
end
