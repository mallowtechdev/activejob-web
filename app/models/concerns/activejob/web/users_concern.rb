# frozen_string_literal: true

module Activejob
  module Web
    module UsersConcern
      extend ActiveSupport::Concern

      def parsed_class_name
        self.class.name.to_s.split('::').last
      end

      def activejob_web_role
        parsed_class_name.to_s.downcase.to_sym
      end
    end
  end
end
