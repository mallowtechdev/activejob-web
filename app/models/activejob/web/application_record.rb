module Activejob
  module Web
    class ApplicationRecord < ApplicationRecord
      self.abstract_class = true

      def self.table_name_prefix
        'activejob_web_'
      end

      def parsed_class_name
        self.class.name.to_s.split('::').last
      end
    end
  end
end