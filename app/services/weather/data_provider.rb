module Weather
  class DataProvider
    def initialize(location)
      @location = location
    end

    def call
      Rails.cache.fetch(cache_key, expires_in: WeatherSettings.cache_expiration) do
        fetch_fresh_data
      end
    end

    private

    attr_reader :location

    def cache_key
      "#{WeatherSettings.cache_key_prefix}/#{location}"
    end

    def fetch_fresh_data
      coordinates = CoordinatesFetcher.new(location).call
      CurrentConditionsFetcher.new(coordinates).call
    end
  end
end
