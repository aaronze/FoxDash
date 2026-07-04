# frozen_string_literal: true

require 'net/http'
require 'json'

class WeatherService
  BASE_URL = 'https://api.open-meteo.com/'
  LOCATION = 'Hamley Bridge 5401'

  ##
  # {"latitude" => -34.34095,
  #  "longitude" => 138.73116,
  #  "generationtime_ms" => 716.3922786712646,
  #  "utc_offset_seconds" => 36000,
  #  "timezone" => "Australia/Sydney",
  #  "timezone_abbreviation" => "GMT+10",
  #  "elevation" => 108.0,
  #  "current_units" => {"time" => "iso8601", "interval" => "seconds", "temperature_2m" => "°C", "weather_code" => "wmo code"},
  #  "current" => {"time" => "2026-05-13T10:00", "interval" => 900, "temperature_2m" => 18.3, "weather_code" => 1},
  #  "daily_units" => {"time" => "iso8601", "weather_code" => "wmo code", "temperature_2m_min" => "°C", "temperature_2m_max" => "°C"},
  #  "daily" =>
  #   {"time" => ["2026-05-13", "2026-05-14", "2026-05-15", "2026-05-16", "2026-05-17", "2026-05-18", "2026-05-19"],
  #    "weather_code" => [3, 53, 55, 63, 51, 51, 51],
  #    "temperature_2m_min" => [13.9, 13.9, 14.6, 13.9, 11.9, 11.1, 11.3],
  #    "temperature_2m_max" => [22.7, 22.6, 22.0, 19.8, 18.1, 17.1, 16.9]}}
  def weather
    path = 'v1/forecast'
    uri = URI("#{BASE_URL}#{path}")
    params = {
      'latitude' => '-34.3576',
      'longitude' => '138.6807',
      'daily' => 'weather_code,temperature_2m_min,temperature_2m_max',
      'current' => 'temperature_2m,weather_code',
      'timezone' => 'Australia/Sydney',
      'forecast_days' => '5'
    }
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    JSON.parse(response.body)
  end
end
