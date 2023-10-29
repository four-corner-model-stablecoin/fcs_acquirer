# frozen_string_literal: true

class Account < ApplicationRecord
  validates :balance, presence: true
  validates :account_number, presence: true
  validates :branch_code, presence: true
  validates :branch_name, presence: true

  belongs_to :merchant

  has_many :account_transactions

  after_initialize do
    self.balance ||= 0.0
    self.account_number ||= "1#{format('%06d', SecureRandom.random_number(10**6))}"
    self.branch_code ||= '101'
    self.branch_name ||= '本店'
  end
end
