class Merchant < ApplicationRecord
  has_one :account
  has_one :wallet
  has_one :did
end
