# frozen_string_literal: true

class AccountTransactionsController < ApplicationController
  def index
    @account = current_merchant.account
    @account_transactions = @account.account_transactions.order(transaction_time: :DESC)
  end
end
