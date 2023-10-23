class Did < ApplicationRecord
  has_one :key
  has_many :contract_as_brand, class_name: 'Contract', foreign_key: 'brand_did_id'
  has_many :contract_as_acquirer, class_name: 'Contract', foreign_key: 'acquirer_did_id'

  belongs_to :merchant, optional: true

  validates :short_form, presence: true

  def self.brand
    find_by(short_form: ENV['BRAND_DID'])
  end
end
