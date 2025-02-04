class FetchCoordinatesService
  require "net/http"

  GEO_URI = "http://api.openweathermap.org/geo/1.0/direct"
  API_KEY = Rails.application.credentials.dig(:openweathermap_api_key)

  class ApiError < StandardError; end

  def initialize(location)
    @location = location
  end

  def call
    response = process_request
    parsed_response = parse_response(response)
    extract_coordinates(parsed_response)
  rescue Timeout::Error => e
    raise ApiError, "Network error: #{e.message}"
  rescue JSON::ParserError => e
    raise ApiError, "Invalid JSON response: #{e.message}"
  end

  private

  attr_reader :location

  def extract_coordinates(data)
    {
      lat: data["lat"],
      lon: data["lon"]
    }
  end

  def process_request
    response = Net::HTTP.get_response(uri)
    raise ApiError, "API request failed with status code: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response
  end

  def parse_response(response)
    parsed_data = JSON.parse(response.body)
    raise ApiError, "Empty response from API" if parsed_data.empty?

    parsed_data.first
  end

  def uri
    URI(GEO_URI).tap do |uri|
      uri.query = URI.encode_www_form(query_params)
    end
  end

  def query_params
    {
      q: location,
      appid: API_KEY,
      limit: 1
    }
  end
end
