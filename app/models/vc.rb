# frozen_string_literal: true

class Vc < ApplicationRecord
  validates :jwt, presence: true

  belongs_to :merchant
end
