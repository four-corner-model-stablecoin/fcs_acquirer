# frozen_string_literal: true

class WalletTransactionsController < ApplicationController
  def index
    @wallet = current_merchant.wallet
    @wallet_transactions = @wallet.wallet_transactions.order(transaction_time: :DESC)
  end
end
