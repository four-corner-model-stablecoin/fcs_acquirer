# frozen_string_literal: true

class WithdrawsController < ApplicationController
  def create
    tx_hex = params[:tx]
    merchant_did = params[:merchant_did]
    merchant = Did.find_by(short_form: merchant_did).merchant

    WithdrawalRequest.create(request_id: params[:request_id], merchant:)

    tx = Tapyrus::Tx.parse_from_payload(tx_hex.htb)

    # TODO: Verify output

    # fill TPC as fee
    utxo = Glueby::Internal::RPC.client.listunspent.first
    tx.in << Tapyrus::TxIn.new(out_point: Tapyrus::OutPoint.from_txid(utxo['txid'], utxo['vout']))
    fee_tapyrus = (0.00003 * (10**8)).to_i
    input_tapyrus = (utxo['amount'].to_f * (10**8)).to_i
    change_tapyrus = input_tapyrus - fee_tapyrus
    tx.out << Tapyrus::TxOut.new(value: change_tapyrus, script_pubkey: Tapyrus::Script.parse_from_addr(Glueby::Internal::RPC.client.getnewaddress))

    # sign for TPC
    script_pubkey = Tapyrus::Script.parse_from_payload(utxo['scriptPubKey'].htb)
    key = Tapyrus::Key.from_wif(Glueby::Internal::RPC.client.dumpprivkey(script_pubkey.to_addr))
    sig_hash = tx.sighash_for_input(1, script_pubkey)
    sig = key.sign(sig_hash) + [Tapyrus::SIGHASH_TYPE[:all]].pack("C")
    tx.in[1].script_sig << sig
    tx.in[1].script_sig << key.pubkey

    render json: { tx: tx.to_hex }
  end

  def confirm
    request_id = params[:request_id]
    request = WithdrawalRequest.find_by(request_id:)

    tx_hex = params[:tx]
    lock_script_hex = params[:lock_script]
    lock_script = Tapyrus::Script.parse_from_payload(lock_script_hex.htb)

    tx = Tapyrus::Tx.parse_from_payload(tx_hex.htb)

    # add sig for token
    acquirer_key = Tapyrus::Key.new(priv_key: Did.first.key.private_key, key_type: 0)
    sig_hash = tx.sighash_for_input(0, lock_script)
    sig = acquirer_key.sign(sig_hash) + [Tapyrus::SIGHASH_TYPE[:all]].pack("C")
    tx.in[0].script_sig << sig

    merchant_to_brand_txid = Glueby::Internal::RPC.client.sendrawtransaction(tx.to_payload.bth)
    generate_block

    request.update!(merchant_to_brand_txid: )

    # TODO: Transaction系の設計よく分からんのでパス

    # MEMO: 本来は非同期に実行、デモではgenerate_blockを用いて同期実行
    # if ENV['DEMO'] = 1
    json = {
      request_id:,
      merchant_to_brand_txid:,
      acquirer_did: request.merchant.did.short_form,
    }.to_json
    response = Net::HTTP.post(
      URI('http://localhost:3001/withdraw/create'),
      json,
      'Content-Type' => 'application/json'
    )
    body = JSON.parse(response.body)

    brand_to_issuer_txid = body['brand_to_issuer_txid']
    burn_txid = body['burn_txid']

    request.update!(brand_to_issuer_txid:, burn_txid:)

    render json: { merchant_to_brand_txid:, brand_to_issuer_txid:, burn_txid: }
  end
end
