# frozen_string_literal: true

require 'activejob/web/version'
require 'activejob/web/engine'
require 'activejob/web/configuration'
require 'cloudwatchlogger'
require 'activejob/web/override_cwl_client'

module Activejob
  module Web
    extend Configuration
  end
end
