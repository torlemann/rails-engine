class Api::V1::Items::MerchantController < ApplicationController
    def index
      if Item.exists?(params[:item_id])
        item = Item.find(params[:item_id])
        render json: MerchantSerializer.new(item.merchant)
      else
        render json: {
          error: 'There are no items with that ID' 
        }, status: 404
      end
    end
  end