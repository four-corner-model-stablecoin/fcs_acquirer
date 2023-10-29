# frozen_string_literal: true

class Did < ApplicationRecord
  validates :short_form, presence: true

  has_one :merchant
  has_one :key
  has_many :contract_as_brand, class_name: 'Contract', foreign_key: 'brand_did_id'
  has_many :contract_as_acquirer, class_name: 'Contract', foreign_key: 'acquirer_did_id'
end
