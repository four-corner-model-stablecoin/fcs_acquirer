# frozen_string_literal: true

class WithdrawsController < ApplicationController
  def create
    tx_hex = params[:tx]
    merchant_did = params[:merchant_did]
    merchant = Did.find_by(short_form: merchant_did).merchant
    amount = params[:amount]

    WithdrawalRequest.create!(request_id: params[:request_id], merchant:, amount:, status: :created)

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
    request = WithdrawalRequest.find_by!(request_id:)
    amount = request.amount

    tx_hex = params[:tx]
    lock_script_hex = params[:lock_script]
    lock_script = Tapyrus::Script.parse_from_payload(lock_script_hex.htb)

    tx = Tapyrus::Tx.parse_from_payload(tx_hex.htb)

    # add sig for token
    acquirer_key = Did.first.key.to_tapyrus_key
    sig_hash = tx.sighash_for_input(0, lock_script)
    sig = acquirer_key.sign(sig_hash) + [Tapyrus::SIGHASH_TYPE[:all]].pack("C")
    tx.in[0].script_sig << sig

    merchant_to_brand_txid = Glueby::Internal::RPC.client.sendrawtransaction(tx.to_payload.bth)

    request.update!(merchant_to_brand_txid:, status: :transfering)

    # MEMO: 本来は非同期に実行、デモではgenerate_blockを用いて同期実行
    # if ENV['DEMO'] = 1
    generate_block

    json = {
      request_id:,
      amount:,
      merchant_to_brand_txid:,
      acquirer_did: Did.first.short_form,
    }.to_json
    response = Net::HTTP.post(
      URI("#{ENV['BRAND_URL']}/withdraw/create"),
      json,
      'Content-Type' => 'application/json'
    )
    body = JSON.parse(response.body)

    brand_to_issuer_txid = body['brand_to_issuer_txid']
    burn_txid = body['burn_txid']

    amount = request.amount
    merchant = request.merchant

    # 加盟店ウォレットを操作
    wallet = merchant.wallet
    wallet.update!(balance: wallet.balance - amount)
    wallet_transaction = WalletTransaction.create(
      wallet:,
      amount:,
      transaction_type: :withdrawal,
      transaction_time: Time.current
    )

    # 加盟店現金口座を操作
    account = merchant.account
    account.update!(balance: account.balance + amount)
    account_transaction = AccountTransaction.create(
      account:,
      amount: -amount,
      transaction_type: :transfer,
      transaction_time: Time.current
    )

    # ステーブルコイン償還履歴作成
    withdrawal_transaction = WithdrawalTransaction.create(
      wallet_transaction:,
      account_transaction:,
      merchant_to_brand_txid:,
      brand_to_issuer_txid:,
      burn_txid:,
      transaction_time: DateTime.current
    )

    request.update!(withdrawal_transaction:, status: :completed)

    render json: { merchant_to_brand_txid:, brand_to_issuer_txid:, burn_txid: }
  end
end
