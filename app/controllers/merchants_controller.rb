class MerchantsController < ApplicationController
    def new; end

    def show
      @merchant = current_merchant
    end

    def create
      @merchant = Merchant.new(merchant_params)
      if @merchant.save!
        flash[:notice] = "登録が完了しました"
        redirect_to root_path
      else
        render 'new'
      end

      sign_in(@merchant)
    end

    private
    def merchant_params
      params.require(:merchant).permit(:merchant_name)
    end
end