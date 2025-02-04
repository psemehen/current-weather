class FetchWeatherService
  require "net/http"

  WEATHER_URI = "https://api.openweathermap.org/data/2.5/weather"
  API_KEY = Rails.application.credentials.dig(:openweathermap_api_key)

  class ApiError < StandardError; end

  def initialize(coordinates)
    @coordinates = coordinates
  end

  def call
    response = process_request
    parsed_response = parse_response(response)
    extract_weather_data(parsed_response)
  rescue Timeout::Error => e
    raise ApiError, "Network error: #{e.message}"
  rescue JSON::ParserError => e
    raise ApiError, "Invalid JSON response: #{e.message}"
  end

  private

  attr_reader :coordinates

  def extract_weather_data(data)
    {
      temp: data["main"]["temp"],
      description: data["weather"].first["main"],
      feels_like: data["main"]["feels_like"]
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

    parsed_data
  end

  def uri
    URI(WEATHER_URI).tap do |uri|
      uri.query = URI.encode_www_form(query_params)
    end
  end

  def query_params
    coordinates.merge({appid: API_KEY})
  end
end
