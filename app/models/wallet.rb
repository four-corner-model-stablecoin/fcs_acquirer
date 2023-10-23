# frozen_string_literal: true

class Wallet < ApplicationRecord
  belongs_to :merchant, optional: true
end
