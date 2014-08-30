require 'pry'
require 'faraday'
require 'faraday_middleware'

class WundergroundClient

  attr_reader :api_key, :client

  def initialize(api_key: )
    @client = Faraday.new(:url => "http://api.wunderground.com/api/#{api_key}/") do |faraday|
      # faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

  end

  def get_history(where:, date:)
    path = "history_#{date.strftime("%Y%m%d")}/q/#{where}.json"
    response = @client.get(path)

    response.body
  end

end