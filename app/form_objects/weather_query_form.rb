class WeatherQueryForm
  include ActiveModel::Model

  attr_accessor :city, :state, :country

  validates :city, presence: true
  validates :country, presence: true, length: {is: 2}
  validates :state, presence: true, length: {is: 2}, if: :us_country?
  validates :state, absence: true, unless: :us_country?

  def self.from_params(params)
    new(
      city: params[:weather_query_form][:city]&.strip&.titleize,
      state: params[:weather_query_form][:state]&.strip&.upcase,
      country: params[:weather_query_form][:country]&.strip&.upcase
    )
  end

  def location
    [city, state, country].compact.join(",")
  end

  private

  def us_country?
    country == "US"
  end
end
