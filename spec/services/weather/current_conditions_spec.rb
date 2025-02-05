require "spec_helper"

RSpec.describe Weather::CurrentConditionsFetcher do
  let(:coordinates) { {lat: 41.3888, lon: 2.159} }
  let(:fetcher) { described_class.new(coordinates) }
  let(:client) { instance_double(Weather::OpenweathermapClient) }

  before do
    allow(Weather::OpenweathermapClient).to receive(:new).and_return(client)
  end

  describe "#call" do
    let(:api_response) do
      {
        "main" => {
          "temp" => 15.5,
          "feels_like" => 14.2
        },
        "weather" => [
          {"main" => "Cloudy"}
        ]
      }
    end

    before do
      allow(client).to receive(:get).and_return(api_response)
    end

    it "calls the OpenWeatherMap API with correct parameters" do
      fetcher.call
      expect(client).to have_received(:get).with(
        Weather::CurrentConditionsFetcher::WEATHER_URI, coordinates
      )
    end

    it "returns the correct weather data" do
      result = fetcher.call
      expect(result).to eq({
        temp: 15.5,
        description: "Cloudy",
        feels_like: 14.2
      })
    end

    context "when the API response is missing data" do
      let(:api_response) { {} }

      it "raises an error" do
        expect { fetcher.call }.to raise_error(NoMethodError)
      end
    end
  end

  describe "private methods" do
    describe "#extract_weather_data" do
      it "extracts weather data from the API response" do
        data = {
          "main" => {"temp" => 20.5, "feels_like" => 19.8},
          "weather" => [{"main" => "Sunny"}]
        }
        result = fetcher.send(:extract_weather_data, data)
        expect(result).to eq({
          temp: 20.5,
          description: "Sunny",
          feels_like: 19.8
        })
      end
    end
  end
end
