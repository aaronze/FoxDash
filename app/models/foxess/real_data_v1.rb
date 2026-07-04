# frozen_string_literal: true

##
#      [{"unit" => "kW", "name" => "PVPower", "variable" => "pvPower", "value" => 0.261},
#       {"unit" => "V", "name" => "PV1Volt", "variable" => "pv1Volt", "value" => 392.4},
#       {"unit" => "A", "name" => "PV1Current", "variable" => "pv1Current", "value" => 1.3},
#       {"unit" => "kW", "name" => "PV1Power", "variable" => "pv1Power", "value" => 0.214},
#       {"unit" => "V", "name" => "PV2Volt", "variable" => "pv2Volt", "value" => 251.4},
#       {"unit" => "A", "name" => "PV2Current", "variable" => "pv2Current", "value" => 0.4},
#       {"unit" => "kW", "name" => "PV2Power", "variable" => "pv2Power", "value" => 0.047},
#       {"unit" => "V", "name" => "PV3Volt", "variable" => "pv3Volt", "value" => 1.3},
#       {"unit" => "A", "name" => "PV3Current", "variable" => "pv3Current", "value" => 0.0},
#       {"unit" => "kW", "name" => "PV3Power", "variable" => "pv3Power", "value" => 0.0},
#       {"unit" => "V", "name" => "PV4Volt", "variable" => "pv4Volt", "value" => 1.1},
#       {"unit" => "A", "name" => "PV4Current", "variable" => "pv4Current", "value" => 0.0},
#       {"unit" => "kW", "name" => "PV4Power", "variable" => "pv4Power", "value" => 0.0},
#       {"unit" => "kW", "name" => "EPSPower", "variable" => "epsPower", "value" => 0.0},
#       {"unit" => "A", "name" => "EPS-RCurrent", "variable" => "epsCurrentR", "value" => 0.5},
#       {"unit" => "V", "name" => "EPS-RVolt", "variable" => "epsVoltR", "value" => 238.5},
#       {"unit" => "kW", "name" => "EPS-RPower", "variable" => "epsPowerR", "value" => 0.0},
#       {"unit" => "A", "name" => "RCurrent", "variable" => "RCurrent", "value" => 1.7},
#       {"unit" => "V", "name" => "RVolt", "variable" => "RVolt", "value" => 239.4},
#       {"unit" => "Hz", "name" => "RFreq", "variable" => "RFreq", "value" => 50.01},
#       {"unit" => "kW", "name" => "RPower", "variable" => "RPower", "value" => 0.327},
#       {"unit" => "℃", "name" => "AmbientTemperature", "variable" => "ambientTemperation", "value" => 46.8},
#       {"unit" => "℃", "name" => "InvTemperation", "variable" => "invTemperation", "value" => 37.5},
#       {"unit" => "℃", "name" => "batTemperature", "variable" => "batTemperature", "value" => 36.4},
#       {"unit" => "kW", "name" => "Load Power", "variable" => "loadsPower", "value" => 0.294},
#       {"unit" => "kW", "name" => "Output Power", "variable" => "generationPower", "value" => 0.327},
#       {"unit" => "kW", "name" => "Feed-in Power", "variable" => "feedinPower", "value" => 0.033},
#       {"unit" => "kW", "name" => "GridConsumption Power", "variable" => "gridConsumptionPower", "value" => 0.0},
#       {"unit" => "V", "name" => "InvBatVolt", "variable" => "invBatVolt", "value" => 418.7},
#       {"unit" => "A", "name" => "InvBatCurrent", "variable" => "invBatCurrent", "value" => 0.1},
#       {"unit" => "kW", "name" => "invBatPower", "variable" => "invBatPower", "value" => 0.066},
#       {"unit" => "kW", "name" => "Charge Power", "variable" => "batChargePower", "value" => 0.0},
#       {"unit" => "kW", "name" => "Discharge Power", "variable" => "batDischargePower", "value" => 0.066},
#       {"unit" => "V", "name" => "BatVolt", "variable" => "batVolt", "value" => 418.0},
#       {"unit" => "A", "name" => "BatCurrent", "variable" => "batCurrent", "value" => 0.6},
#       {"unit" => "kW", "name" => "MeterPower", "variable" => "meterPower", "value" => -0.033},
#       {"unit" => "kW", "name" => "Meter2Power", "variable" => "meterPower2", "value" => 0.0},
#       {"unit" => "%", "name" => "SoC", "variable" => "SoC", "value" => 58.0},
#       {"unit" => "kWh", "name" => "Cumulative power generation", "variable" => "generation", "value" => 141.7},
#       {"unit" => "0.01kWh", "name" => "Battery Residual Energy", "variable" => "ResidualEnergy", "value" => 40.32},
#       {"name" => "Running State", "variable" => "runningState", "value" => "163"},
#       {"name" => "Battery Status", "variable" => "batStatus", "value" => "2"},
#       {"name" => "Battery Status Name", "variable" => "batStatusV2", "value" => "Discharge"},
#       {"name" => "The current error code is reported", "variable" => "currentFault", "value" => ""},
#       {"name" => "The number of errors", "variable" => "currentFaultCount", "value" => "0"},
#       {"unit" => "kWh", "name" => "Battery throughput", "variable" => "energyThroughput", "value" => 194.44},
#       {"unit" => "%", "name" => "SOH", "variable" => "SOH", "value" => 100.0},
#       {"unit" => "kWh", "name" => "Total grid electricity consumption", "variable" => "gridConsumption", "value" => 0.2},
#       {"unit" => "kWh", "name" => "Total electricity consumption of Meter 2", "variable" => "gridConsumption2", "value" => 0.0},
#       {"unit" => "kWh", "name" => "Load power consumption", "variable" => "loads", "value" => 129.0},
#       {"unit" => "kWh", "name" => "The total energy of the feeder", "variable" => "feedin", "value" => 11.4},
#       {"unit" => "kWh", "name" => "Total feed network electricity consumption for Meter 2", "variable" => "feedin2", "value" => 0.0},
#       {"unit" => "kWh", "name" => "Total charge energy", "variable" => "chargeEnergyToTal", "value" => 90.3},
#       {"unit" => "kWh", "name" => "Total discharge energy", "variable" => "dischargeEnergyToTal", "value" => 157.5},
#       {"unit" => "kWh", "name" => "Photovoltaic power generation", "variable" => "PVEnergyTotal", "value" => 179.9},
#       {"unit" => "A", "name" => "Maximum charge current", "variable" => "maxChargeCurrent", "value" => 50.0},
#       {"unit" => "A", "name" => "Maximum discharge current", "variable" => "maxDischargeCurrent", "value" => 50.0},
#       {"unit" => "Ah", "name" => "Remaining power capability", "variable" => "RemainingPowerCapability", "value" => 20.144},
#       {"unit" => "Ah", "name" => "Remaining capacity", "variable" => "remainCapacity", "value" => 100.0},
#       {"unit" => "kWh", "name" => "Battery total discharge energy", "variable" => "totalDischargeKW", "value" => 85.8},
#       {"unit" => "Ah", "name" => "Battery total discharge capacity", "variable" => "totalDischargeAh", "value" => 209.8},
#       {"name" => "Battery cycle count", "variable" => "batCycleCount", "value" => "2"}]

module Foxess
  class RealDataV1
    attr_accessor :data
    attr_accessor :ambient_temperature, :inverter_temperature, :bat_temperature, :loads_power, :generation_power
    attr_accessor :feedin_power, :grid_consumption_power, :bat_charge_power, :bat_discharge_power, :soc, :current_fault
    attr_accessor :current_fault_count, :soh, :bat_cycle_count

    VARIABLES = [
      'ambientTemperation', # Ambient Temperature ℃
      'invTemperation', # Inverter Temperature ℃
      'batTemperature', # Battery Temperature ℃ (Average?)
      'loadsPower', # Load power kW (Current load, i.e. Home usage)
      'generationPower', # Generation power kW (-battery charging??)
      'feedinPower', # Feed-in power kW (Current export power)
      'gridConsumptionPower', # Grid consumption power kW (Grid importing power)
      'batChargePower', # Battery charge power kW (0 when discharging)
      'batDischargePower', # Battery discharge power kW (0 when charging)
      'SoC', # Battery state of charge %
      'currentFault', # Current error code, empty string if none
      'currentFaultCount', # Number of errors, 0 if none
      'SOH', # Battery health %
      'batCycleCount', # Number of battery cycles
    ]

    def initialize(datas)
      @data = {}

      datas.each do |datum|
        @data[datum['variable']] = datum['value']
      end

      @ambient_temperature = @data['ambientTemperation']
      @inverter_temperature = @data['invTemperation']
      @bat_temperature = @data['batTemperature']
      @loads_power = @data['loadsPower']
      @generation_power = @data['generationPower']
      @feedin_power = @data['feedinPower']
      @grid_consumption_power = @data['gridConsumptionPower']
      @bat_charge_power = @data['batChargePower']
      @bat_discharge_power = @data['batDischargePower']
      @soc = @data['SoC']
      @current_fault = @data['currentFault']
      @current_fault_count = @data['currentFaultCount']
      @soh = @data['SOH']
      @bat_cycle_count = @data['batCycleCount']
    end
  end
end