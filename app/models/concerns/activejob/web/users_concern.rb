module Activejob
  module Web
    module UsersConcern
      extend ActiveSupport::Concern

      # USER_MODELS = %w[Admin Common Approver Executor].freeze

      def parsed_class_name
        self.class.name.to_s.split('::').last
      end

      def activejob_web_role
        parsed_class_name.to_s.downcase.to_sym
      end
    end
  end
end