class ApplicationController < ActionController::Base
    helper_method :current_merchant, :signed_in?

  private

  def sign_in(merchant)
    session[:merchant_id] = merchant.id
  end

  def sign_out
    session[:merchant_id] = nil
  end

  def current_merchant
    @current_merchant ||= Merchant.find_by(id: session[:merchant_id]) if session[:merchant_id]
  end

  def signed_in?
    return if current_merchant

    redirect_to login_path
  end
end
