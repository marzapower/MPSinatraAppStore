require 'sinatra'
require 'sequel'
require 'json'
require 'rest-open-uri'

require './db'

DEGUB = true
Purchase = DB[:purchase]

##
## Verifies with Apple that the receipt is valid
##
post '/verifyReceipt'  do
  content_type 'application/json'
  result = open(appleURL(), :method => :post, :body => {"receipt-data" => params[:receipt_data]}.to_json)
  json = JSON.parse(result.string)
  if (json[:status].to_i == 0)
    result(0, json)
  else
    result(1, json.merge({:original_receipt => params[:receipt_data]}))
  end
end

##
## Registers a purchase in the local database
##
post '/registerPurchase' do
  begin
    Purchase.insert({
                      :product_identifier => params[:product_identifier],
                      :device_id => params[:device_id],
                      :bought_at => Date.new
    })

    result(0)
  rescue Exception => e
    result(1, nil, e)
  end
end

##
## Gathers local data to see if a purchase is valid or not,
## and also checks if it's validity expired or not (if needed)
##
post '/verifyPurchase' do
  purchase = Purchase.where({
                              :product_identifier => params[:product_identifier],
                              :device_id => params[:device_id]
  }).first

  res = {:purchased => purchase.nil?}

  if !purchase.nil? and !purchase[:expires_at].nil?
    res.merge!({:expired => Date.new >= purchase[:expires_at]})
  end

  result(0, res)
end

private

def log_error(error, result = {})
  result.merge! ({"error" => {"message" => error.message}}) unless error.nil?
  result
end

def result(value, data = nil, error = nil)
  result = {"result" => value}
  result.merge! ({:data => data}) unless data.nil?
  log_error(error, result).to_json
end

def appleURL
  if DEGUB
    "https://sandbox.itunes.apple.com/verifyReceipt"
  else
    "https://buy.itunes.apple.com/verifyReceipt"
  end
end
