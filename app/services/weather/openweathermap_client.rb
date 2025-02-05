require "net/http"

module Weather
  class OpenweathermapClient
    API_KEY = Rails.application.credentials.dig(:openweathermap_api_key)

    class ApiError < StandardError; end

    def get(url, params = {})
      uri = build_uri(url, params)
      response = process_request(uri)
      parse_response(response)
    rescue Timeout::Error => e
      raise ApiError, "Network timeout error: #{e.message}"
    rescue SocketError => e
      raise ApiError, "Network connection error: #{e.message}"
    rescue JSON::ParserError => e
      raise ApiError, "Invalid JSON response: #{e.message}"
    rescue => e
      raise ApiError, "Unexpected error occurred: #{e.message}"
    end

    private

    def build_uri(url, params)
      URI(url).tap do |uri|
        uri.query = URI.encode_www_form(params.merge(appid: API_KEY))
      end
    end

    def process_request(uri)
      response = Net::HTTP.get_response(uri)
      raise ApiError, "API request failed with status code: #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response
    end

    def parse_response(response)
      parsed_data = JSON.parse(response.body)
      raise ApiError, "Empty response from API" if parsed_data.empty?

      parsed_data
    end
  end
end
