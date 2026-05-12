# frozen_string_literal: true

require 'time'
require 'models/telemetry'

class TelemetryService
  def self.store_telemetry(telemetry)
    telemetry.each do |timestamp, variables|
      begin
        Models::Telemetry.create!(timestamp: Time.parse(timestamp).utc, **variables)
      rescue ActiveRecord::RecordNotUnique
        # Do nothing
      end
    end
  end
end
