class WeatherQueryForm
  include ActiveModel::Model

  attr_accessor :city, :state, :country

  validates :city, presence: true
  validates :country, presence: true, length: {is: 2}
  validates :state, presence: true, if: :us_country?
  validates :state, absence: true, unless: :us_country?
  validate :state_length_if_present

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

  def state_length_if_present
    return if state.blank?

    errors.add(:state, :invalid_length) unless state.length == 2
  end
end
