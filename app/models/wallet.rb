# frozen_string_literal: true

# 加盟店ウォレットモデル
# カストディ型なのでDB上で非同期的に残高を反映させるのみ
# TODO: 送金された際に直を更新する必要がある
class Wallet < ApplicationRecord
  has_many :wallet_transactions
  belongs_to :merchant, optional: true
end
