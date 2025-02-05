require "spec_helper"

RSpec.describe Weather::CoordinatesFetcher do
  let(:location) { "Barcelona,Spain" }
  let(:fetcher) { described_class.new(location) }
  let(:client) { instance_double(Weather::OpenweathermapClient) }

  before do
    allow(Weather::OpenweathermapClient).to receive(:new).and_return(client)
  end

  describe "#call" do
    let(:api_response) do
      [
        {
          "name" => "Barcelona",
          "lat" => 41.3888,
          "lon" => 2.159
        }
      ]
    end

    before do
      allow(client).to receive(:get).and_return(api_response)
    end

    it "calls the OpenWeatherMap API with correct parameters" do
      fetcher.call
      expect(client).to have_received(:get).with(
        Weather::CoordinatesFetcher::GEO_URI, {q: location, limit: 1}
      )
    end

    it "returns the correct coordinates" do
      result = fetcher.call
      expect(result).to eq({lat: 41.3888, lon: 2.159})
    end

    context "when the API returns an empty response" do
      let(:api_response) { [] }

      it "raises an error" do
        expect { fetcher.call }.to raise_error(NoMethodError)
      end
    end
  end

  describe "private methods" do
    describe "#extract_coordinates" do
      it "extracts lat and lon from the data" do
        data = {"lat" => 41.3888, "lon" => 2.159}
        result = fetcher.send(:extract_coordinates, data)
        expect(result).to eq({lat: 41.3888, lon: 2.159})
      end
    end
  end
end
