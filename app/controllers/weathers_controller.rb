class WeathersController < ApplicationController
  rescue_from FetchCoordinatesService::ApiError, FetchWeatherService::ApiError, with: :handle_api_error
  def show
    return unless submitted?
    return unless valid_params?

    fetch_weather_data
  end

  private

  def valid_params?
    sanitize_params

    valid_city? && valid_country? && valid_state?
  end

  def sanitize_params
    @city = params[:city]&.strip&.titleize
    @state = params[:state]&.strip&.upcase
    @country = params[:country]&.strip&.upcase
  end

  # Use I18n instead of hardcoded error messages
  def valid_city?
    return true if @city.present?

    flash.now[:alert] = "City is required"
    false
  end

  def valid_country?
    return true if @country.present? && @country.length == 2

    flash.now[:alert] = "Country code is required and should be 2 letters"
    false
  end

  def valid_state?
    if @country == "US"
      return true if @state.present? && @state.length == 2

      flash.now[:alert] = "State is required for US and should be 2 letters"
    else
      return true if @state.blank?

      flash.now[:alert] = "State should be blank for non-US countries"
    end
    false
  end

  def fetch_weather_data
    location = [@city, @state, @country].compact.join(",")
    coordinates = FetchCoordinatesService.new(location).call
    @weather_data = FetchWeatherService.new(coordinates).call
  end

  # To avoid validation on the first page load. Hidden field passed in the form.
  def submitted?
    params[:submitted] == "true"
  end

  def handle_api_error(e)
    Rails.logger.error("Weather API error: #{e.message}")
    flash.now[:alert] = "Could not fetch weather data, please try again."
  end
end
