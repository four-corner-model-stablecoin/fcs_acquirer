# frozen_string_literal: true

class WalletTransaction < ApplicationRecord
  validates :amount, presence: true
  validates :transaction_type, presence: true
  validates :transaction_time, presence: true

  has_one :withdrawal_transaction
  belongs_to :wallet

  enum transaction_type: {
    deposit: 0, # 入金
    withdrawal: 1, # 出金
    transfer: 2 # 口座振替
  }
end
