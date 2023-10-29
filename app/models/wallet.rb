# frozen_string_literal: true

class Wallet < ApplicationRecord
  has_many :wallet_transactions
  belongs_to :merchant, optional: true
end
