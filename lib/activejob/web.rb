# frozen_string_literal: true

require 'activejob/web/version'
require 'activejob/web/engine'

module Activejob
  module Web
    mattr_accessor :job_approvers_class, default: 'User'
    mattr_accessor :job_executors_class, default: 'User'
    mattr_accessor :job_admins_class, default: 'User'
  end
end
