# frozen_string_literal: true

module Activejob
  module Web
    module JobsHelper
      def common_model?
        !admin? && Activejob::Web.is_common_model
      end
    end
  end
end
