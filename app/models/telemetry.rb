# frozen_string_literal: true

require 'time'

class Telemetry < ApplicationRecord
  validates :timestamp, presence: true, uniqueness: true
  validates :inverter_temperature, :battery_temperature, :battery_soc,
            :power_load, :grid_feed_in, :grid_consumption,
            :battery_discharge_rate, :battery_charge_rate, numericality: true, allow_nil: true

  scope :last_day, -> { where('timestamp >= ?', Time.now - (60 * 60 * 24)).order(:timestamp) }
end
