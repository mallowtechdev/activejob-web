module Activejob
  module Web
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true

      default_scope { order(created_at: :desc) }

      def self.table_name_prefix
        'activejob_web_'
      end

      def parsed_class_name
        self.class.name.to_s.split('::').last
      end
    end
  end
end