require "rails_helper"

RSpec.describe Weather::DataProvider do
  describe "#call" do
    let(:location) { "London" }
    let(:data_provider) { Weather::DataProvider.new(location) }

    before do
      allow(data_provider).to receive(:fetch_fresh_data).and_return("Sample Weather Data")
    end

    it "fetches and returns weather data" do
      expect(data_provider.call).to eq("Sample Weather Data")
    end

    it "caches the fetched data" do
      expect(Rails.cache).to receive(:fetch) do |key, options|
        options[:expires_in] = WeatherSettings.cache_expiration
        nil
      end

      data_provider.call
    end

    it "returns cached data on subsequent calls" do
      expect(Rails.cache).to receive(:fetch).and_return("Cached Weather Data")
      expect(data_provider.call).to eq("Cached Weather Data")
    end
  end

  describe "#fetch_fresh_data" do
    context "when coordinates are fetched successfully" do
      let(:location) { "London" }
      let(:data_provider) { Weather::DataProvider.new(location) }

      before do
        allow(Weather::CoordinatesFetcher).to receive(:new)
          .and_return(instance_double(Weather::CoordinatesFetcher,
            call: {lat: 51.5074, lng: -0.1278}))
        allow(Weather::CurrentConditionsFetcher).to receive(:new)
          .and_return(instance_double(Weather::CurrentConditionsFetcher,
            call: {temp: 22.5, conditions: "Sunny",
                   feels_like: 23.5}))
      end

      it "fetches coordinates and current conditions" do
        expect(Weather::CoordinatesFetcher).to receive(:new).with(location)
          .and_return(instance_double(Weather::CoordinatesFetcher,
            call: {lat: 51.5074,
                   lng: -0.1278}))
        expect(Weather::CurrentConditionsFetcher).to receive(:new).with({lat: 51.5074, lng: -0.1278})
          .and_return(
            instance_double(Weather::CurrentConditionsFetcher,
              call: {temp: 22.5,
                     conditions: "Sunny",
                     feels_like: 23.5})
          )
        data = data_provider.send(:fetch_fresh_data)
        expect(data).to eq({temp: 22.5, conditions: "Sunny", feels_like: 23.5})
      end
    end

    context "when coordinates are not fetched successfully" do
      let(:location) { "London" }
      let(:data_provider) { Weather::DataProvider.new(location) }

      it "handles exceptions when fetching coordinates" do
        allow(Weather::CoordinatesFetcher).to receive(:new).and_raise("Coordinates not found")
        expect { data_provider.send(:fetch_fresh_data) }.to raise_error("Coordinates not found")
      end

      it "handles exceptions when fetching current conditions" do
        allow(Weather::CoordinatesFetcher).to receive(:new).and_return(instance_double(Weather::CoordinatesFetcher, call: {lat: 51.5074, lng: -0.1278}))
        allow(Weather::CurrentConditionsFetcher).to receive(:new).and_raise("Failed to fetch conditions")
        expect { data_provider.send(:fetch_fresh_data) }.to raise_error("Failed to fetch conditions")
      end
    end
  end
end
