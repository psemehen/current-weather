module Weather
  class CurrentConditionsFetcher
    WEATHER_URI = "https://api.openweathermap.org/data/2.5/weather".freeze

    def initialize(coordinates)
      @coordinates = coordinates
      @client = OpenweathermapClient.new
    end

    def call
      response = @client.get(WEATHER_URI, @coordinates)
      extract_weather_data(response)
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
  end
end
