# frozen_string_literal: true

class TelemetriesController < ApplicationController
  def battery
    telemetries = Telemetry.last_day.pluck(:timestamp, :battery_soc)

    render json: telemetries.map { |timestamp, battery_soc| { timestamp:, battery_soc: } }
  end

  def solar
    telemetries = Telemetry.last_day.pluck(:timestamp, :battery_charge_rate)

    render json: telemetries.map { |timestamp, battery_charge_rate| { timestamp:, battery_charge_rate: } }
  end

  def fetch
    telemetry = FoxessService.new.telemetry
    TelemetryService.store_telemetry(telemetry)
  end

  def poll
    telemetry = FoxessService.new.telemetry(60 * 10)
    TelemetryService.store_telemetry(telemetry)
  end
end
