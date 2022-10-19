require 'rails_helper'

RSpec.describe 'Items API' do 
    before :each do
        @merchant_1 = create(:merchant)
    end

    it 'sends a list of all items' do 
    merchant_2 = create(:merchant)
    create_list(:item, 3, merchant_id: @merchant_1.id)
    create_list(:item, 3, merchant_id: merchant_2.id)

    get '/api/v1/items'

    items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(items[:data].count).to eq(6)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)
    end
  end 

  it 'can get one item by its id' do 
    item = create(:item, merchant_id: @merchant_1.id)

    get "/api/v1/items/#{item.id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful 

    expect(item[:data]).to have_key(:id)
    expect(item[:data][:id]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:name)
    expect(item[:data][:attributes][:name]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:description)
    expect(item[:data][:attributes][:description]).to be_a(String)

    expect(item[:data][:attributes]).to have_key(:unit_price)
    expect(item[:data][:attributes][:unit_price]).to be_a(Float)
  end 

  it 'can create an item' do 
    item_params = ({
      name: 'this is an item',
      description: 'hopefully this item is being created',
      unit_price: 2.5,
      merchant_id: @merchant_1.id
    })

    headers = {"CONTENT_TYPE" => "application/json"}
    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    item = Item.last

    expect(response).to be_successful

    expect(item.name).to eq(item_params[:name])
    expect(item.description).to eq(item_params[:description])
    expect(item.unit_price).to eq(item_params[:unit_price])
  end 

  it 'can edit an existing item' do 
    item = create(:item, merchant_id: @merchant_1.id)

    old_name = item.name
    item_params = {
      name: 'A new name', 
      merchant_id: @merchant_1.id
    }

    headers = {"CONTENT_TYPE" => "application/json"}
    patch "/api/v1/items/#{item.id}", headers: headers, params: JSON.generate(item: item_params)
    item = Item.last

    expect(response).to be_successful
    expect(item.name).to_not eq(old_name)
    expect(item.name).to eq("A new name")
  end 

  it 'can delete an item' do 
    item = create(:item, merchant_id: @merchant_1.id)

    expect(Item.count).to eq(1)
    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end 

  it "can return the merchant for a given item" do
    merchant = create(:merchant)
    item = create(:item, merchant_id: merchant.id)
    
    get "/api/v1/items/#{item.id}/merchant"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to be_an String 

    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to be_a Hash
    
    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to be_an String
  end
end 