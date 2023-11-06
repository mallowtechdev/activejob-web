# frozen_string_literal: true

require 'test_helper'

module Activejob
  class WebTest < ActiveSupport::TestCase
    test 'it has a version number' do
      assert Activejob::Web::VERSION
    end
  end
end
