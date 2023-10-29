# frozen_string_literal: true

class Merchant < ApplicationRecord
  validates :merchant_name, presence: true, length: { maximum: 255 }, uniqueness: true

  has_one :account
  has_one :wallet
  belongs_to :did
end
