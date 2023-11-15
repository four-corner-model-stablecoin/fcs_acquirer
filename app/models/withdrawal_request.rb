# frozen_string_literal: true

# ステーブルコイン償還リクエストモデル
class WithdrawalRequest < ApplicationRecord
  validates :request_id, presence: true
  validates :amount, presence: true

  belongs_to :merchant
  belongs_to :withdrawal_transaction, optional: true

  enum status: {
    created: 0,
    completed: 1,
    transfering: 2,
    failed: 9
  }
end
