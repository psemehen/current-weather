require "rails_helper"

RSpec.describe WeathersController, type: :controller do
  let(:valid_params) do
    {
      weather_query_form: {
        city: "New York",
        state: "NY",
        country: "US"
      }
    }
  end

  let(:invalid_params) do
    {
      weather_query_form: {
        city: "",
        country: "USA"
      }
    }
  end

  describe "GET #show" do
    context "when no form submission" do
      it "responds successfully" do
        get :show
        expect(response).to be_successful
      end

      it "does not attempt to fetch weather data" do
        expect(Weather::DataProvider).not_to receive(:new)
        get :show
      end
    end

    context "with invalid form submission" do
      before { get :show, params: invalid_params }

      it "sets flash alert with error messages" do
        expect(flash[:alert]).to include("City can't be blank")
        expect(flash[:alert]).to include("Country is the wrong length")
      end

      it "responds successfully" do
        expect(response).to be_successful
      end
    end

    context "with valid form submission" do
      let(:mock_weather_data) { {temp: 22.5, description: "Sunny", feels_like: 21} }
      let(:mock_location) { instance_double("Location") }
      let(:mock_form) { instance_double(WeatherQueryForm, valid?: true, location: mock_location) }

      before do
        allow(WeatherQueryForm).to receive(:from_params).and_return(mock_form)
        allow(Weather::DataProvider).to receive(:new).and_return(
          instance_double(Weather::DataProvider, call: mock_weather_data)
        )

        get :show, params: valid_params
      end

      it "fetches weather data using the data provider" do
        expect(Weather::DataProvider).to have_received(:new).with(mock_location)
      end

      it "responds successfully" do
        expect(response).to be_successful
      end
    end

    context "when API returns error" do
      before do
        allow(Weather::DataProvider).to receive_message_chain(:new, :call)
          .and_raise(Weather::OpenweathermapClient::ApiError.new("API unavailable"))

        get :show, params: valid_params
      end

      it "sets flash alert" do
        expect(flash[:alert]).to eq("Could not fetch weather data, please try again.")
      end

      it "redirects to weather path" do
        expect(response).to redirect_to(weather_path)
      end
    end
  end

  describe "form submission handling" do
    it "detects form submission" do
      post :show, params: {weather_query_form: {city: "Lviv", country: "UA"}}
      expect(controller.send(:form_submitted?)).to be true
    end

    it "handles missing form params gracefully" do
      get :show, params: {unrelated_param: "test"}
      expect(controller.send(:form_submitted?)).to be false
    end
  end
end
