class SessionsController < ApplicationController
    def new; end
  
    def create
      merchant = Merchant.find_by(merchant_name: session_params[:merchant_name])
      sign_in(merchant) if merchant
      
      redirect_to root_path
    end
  
    def destroy
      sign_out
      
      redirect_to root_path
    end
  
    private
  
    def session_params
      params.require(:session).permit(:merchant_name)
    end
  end
