# frozen_string_literal: true

# ブランドとの契約を管理するモデル
# 現状使い道がないので仮
class Contract < ApplicationRecord
  belongs_to :brand_did, class_name: 'Did', foreign_key: 'brand_did_id'
  belongs_to :acquirer_did, class_name: 'Did', foreign_key: 'acquirer_did_id'

  validates :contracted_at, presence: true
  validates :effect_at, presence: true
  validates :expire_at, presence: true
end
