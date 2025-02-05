class WeathersController < ApplicationController
  rescue_from Weather::OpenweathermapClient::ApiError, with: :handle_api_error

  def show
    @form = WeatherQueryForm.new
    return unless form_submitted?

    fetch_weather_data if form_valid?
  end

  private

  def form_submitted?
    params[:weather_query_form].present?
  end

  def form_valid?
    @form = WeatherQueryForm.from_params(params)
    return true if @form.valid?

    flash.now[:alert] = @form.errors.full_messages.to_sentence
    false
  end

  def fetch_weather_data
    @weather_data = Weather::DataProvider.new(@form.location).call
  end

  def handle_api_error(e)
    Rails.logger.error("Weather API error: #{e.message}")
    flash[:alert] = "Could not fetch weather data, please try again."
    redirect_to weather_path
  end
end
