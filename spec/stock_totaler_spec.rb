require_relative '../stock_totaler'
require 'webmock/rspec'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
end 

RSpec.describe 'stock totaler', :vcr do
  it "calculates stock share value" do
    total_value = calculate_total('TSLA', 2)
    expect(total_value).to equal(651.2)
  end

  it 'handles an invalid stock symbol' do
    expect { calculate_total('ZZZZ', 2)}.to raise_error(SymbolNotFound, /No symbol matches/)
  end

  it 'handles an exception from Faraday' do
    stub_request(:get, 'http://dev.markitondemand.com/MODApis/Api/v2/Quote/json?symbol=ZZZZ').to_timeout

    expect { calculate_total('ZZZZ', 2)}.to raise_error(RequestFailed, /execution expired/)
  end
end