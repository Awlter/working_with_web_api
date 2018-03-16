require 'json'
require 'faraday'

class SymbolNotFound < StandardError; end
class RequestFailed < StandardError; end

def calculate_total(symbol, quantity)
  url = 'http://dev.markitondemand.com/MODApis/Api/v2/Quote/json'
  http_client = Faraday.new
  response = http_client.get(url, symbol: symbol)
  data = JSON.load(response.body)
  price = data["LastPrice"]

  raise SymbolNotFound, data['Message'] unless price

  price.to_f * quantity.to_i

rescue Faraday::Error => e
  raise RequestFailed, e.message, e.backtrace
end

if __FILE__ == $0
  symbol, quantity = ARGV
  puts calculate_total(symbol, quantity)
end