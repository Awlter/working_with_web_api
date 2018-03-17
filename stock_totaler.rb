require 'json'
require 'faraday'

class SymbolNotFound < StandardError; end
class RequestFailed < StandardError; end

class MarkitClient
  attr_reader :http_client

  def initialize(http_client=Faraday.new)
    @http_client = http_client
  end

  def last_price(symbol)
    url = 'http://dev.markitondemand.com/MODApis/Api/v2/Quote/json'
    response = http_client.get(url, symbol: symbol)
    data = JSON.load(response.body)
    price = data["LastPrice"]

    raise SymbolNotFound, data['Message'] unless price

    price.to_f
  rescue Faraday::Error => e
    raise RequestFailed, e.message, e.backtrace
  end
end

def calculate_total(symbol, quantity)
  markit_client = MarkitClient.new
  price = markit_client.last_price(symbol)

  price * quantity.to_i
end

if __FILE__ == $0
  symbol, quantity = ARGV
  puts calculate_total(symbol, quantity)
end