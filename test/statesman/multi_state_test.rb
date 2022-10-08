# frozen_string_literal: true

require 'test_helper'

module Statesman
  class MultiStateTest < ActiveSupport::TestCase
    test 'it has a version number' do
      assert Statesman::MultiState::VERSION
    end
  end
end
