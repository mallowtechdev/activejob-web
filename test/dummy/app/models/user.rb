# frozen_string_literal: true

class User < ApplicationRecord

  # == Validations ===================================================================================================
  validates :name, presence: true, length: { maximum: 50 }

  def admin?
    is_admin
  end
end
