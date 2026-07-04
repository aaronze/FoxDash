# frozen_string_literal: true

require 'services/weather_service'

class WeatherController < ApplicationController
  def index
    service = WeatherService.new
    weather = service.weather
    render json: weather
  end
end