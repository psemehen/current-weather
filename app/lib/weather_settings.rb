module WeatherSettings
  module_function

  def cache_expiration
    30.minutes
  end

  def cache_key_prefix
    "weather_data"
  end
end
