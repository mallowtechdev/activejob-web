require 'activejob/web/version'
require 'activejob/web/engine'

module Activejob
  module Web
    mattr_accessor :job_approvers_class
    mattr_accessor :job_executors_class
  end
end
