# Weather Service

## Features Implemented
- Current weather retrieval based on City, State (US only), and Country Code.
- Error handling.
- Caching for 30 minutes.
- Basic test coverage using RSpec.
- Linting with `standard`.
- CI updates.

## Details

### Current Weather Retrieval
The service supports fetching current weather conditions for a given location. Users can provide:
- City name.
- State (for US locations only).
- Country code.

## Room for improvements
- Expand test coverage(small % covered).
- Add more detailed weather information.
- Add stylings.

## Running the App Locally
1. Make sure `ruby` is installed - version 3.3.6.
2. Run `bundle install` to install dependencies.
3. Run `rspec` to run specs.
4. Run `standardrb --fix` to resolve linter offenses.
5. Register at http://api.openweathermap.org to obtain your API key. Add API key to `credentials` as 
`openweathermap_api_key: YOUR_API_KEY` with cmd `rails credentials:edit`.
6. Start the server with `rails s`.
7. The application should be running at `http://localhost:3000`.
