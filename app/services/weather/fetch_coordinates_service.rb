require "net/http"

module Weather
  class FetchCoordinatesService
    GEO_URI = "http://api.openweathermap.org/geo/1.0/direct".freeze

    def initialize(location)
      @location = location
      @client = OpenweathermapClient.new
    end

    def call
      response = @client.get(GEO_URI, query_params)
      extract_coordinates(response.first)
    end

    private

    attr_reader :location

    def extract_coordinates(data)
      {
        lat: data["lat"],
        lon: data["lon"]
      }
    end

    def query_params
      {
        q: location,
        limit: 1
      }
    end
  end
end
