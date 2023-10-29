# frozen_string_literal: true

class ContractsController < ApplicationController
  def new; end

  def create
    acquirer_did = Did.first

    # brandへ契約リクエストを送る
    json = {
      name: 'tapyrus_acquirer',
      did: acquirer_did.short_form,
    }.to_json
    response = Net::HTTP.post(
      URI("#{ENV['BRAND_URL']}/contracts/agreement/acquirer"),
      json,
      'Content-Type' => 'application/json'
    )
    body = JSON.parse(response.body)

    # 返答を受け取る
    brand_did_short_form = body['brand_did']
    contracted_at = body['contracted_at']
    effect_at = body['effect_at']
    expire_at = body['expire_at']

    brand_did = Did.find_or_create_by(short_form: brand_did_short_form)
    contract_with_brand = Contract.create(acquirer_did:, brand_did:, contracted_at:, effect_at:, expire_at:)

    redirect_to root_path
  end
end
