require 'digest'
require 'net/http'
require 'json'

class FoxessService
  BASE_URL = 'https://www.foxesscloud.com'
  ACCESS_TOKEN = '23e7ffa1-6e4e-4922-8559-24536d4fe649'
  SERIAL_NUMBER = '60KB103061FA061'
  DAY_IN_SECONDS = 60 * 60 * 24

  VARIABLES = {
    'invTemperation' => 'inverter_temperature',
    'batTemperature' => 'battery_temperature',
    'SoC' => 'battery_soc',
    'loadsPower' => 'power_load',
    'feedinPower' => 'grid_feed_in',
    'gridConsumptionPower' => 'grid_consumption',
    'batChargePower' => 'battery_charge_rate',
    'batDischargePower' => 'battery_discharge_rate',
  }.freeze

  WORK_MODES = [
    'SelfUse' => 'SelfUse',
    'Feedin' => 'Feedin',
    'Backup' => 'Backup',
    'ForceCharge' => 'ForceCharge',
    'ForceDischarge' => 'ForceDischarge',
  ]

  DEFAULT_GROUPS = [
    {
      'enable' => 1,
      'startHour' => 10,
      'startMinute' => 01,
      'endHour' => 10,
      'endMinute' => 59,
      'workMode' => 'ForceDischarge',
      'extraParam' => {
        'importLimit' => 14500,
        'exportLimit' => 10500,
        'fdSoc' => 25
      }
    },
    {
      'enable' => 1,
      'startHour' => 11,
      'startMinute' => 02,
      'endHour' => 13,
      'endMinute' => 59,
      'workMode' => 'ForceCharge',
      'extraParam' => {
        'importLimit' => 14500,
        'exportLimit' => 10500,
        'fdSoc' => 95
      }
    },
    {
      'enable' => 1,
      'startHour' => 18,
      'startMinute' => 1,
      'endHour' => 19,
      'endMinute' => 59,
      'workMode' => 'ForceDischarge',
      'extraParam' => {
        'importLimit' => 14500,
        'exportLimit' => 10500,
        'fdSoc' => 55,
      }
    },
    {
      'enable' => 1,
      'startHour' => 0,
      'startMinute' => 0,
      'endHour' => 23,
      'endMinute' => 59,
      'workMode' => 'SelfUse',
      'extraParam' => {
        'importLimit' => 14500,
        'exportLimit' => 10500,
        'fdSoc' => 10,
      }
    }
  ]

  def get_schedule
    post('/op/v3/device/scheduler/get', { deviceSN: SERIAL_NUMBER })
  end

  def set_schedule(groups: DEFAULT_GROUPS)
    params = {
      'deviceSN' => SERIAL_NUMBER,
      'groups' => groups
    }

    post('/op/v3/device/scheduler/enable', params)
  end

  ##
  #    [{"deviceType" => "KH10",
  #       "hasBattery" => true,
  #       "hasPV" => true,
  #       "stationName" => "FoxESS KH10",
  #       "moduleSN" => "609W6EMF61DB757",
  #       "deviceSN" => "60KB103061FA061",
  #       "productType" => "KH",
  #       "stationID" => "7d720b5c-a734-4971-a396-6d6898a1c594",
  #       "status" => 1}],
  def device_list
    post('/op/v0/device/list', { current_page: 1, page_size: 10 })
  end

  def offboard
    post('/op/v0/vpp/oauth2/client/offboard', { deviceSN: SERIAL_NUMBER })
  end

  ##
  #  "result" =>
  #   [{"datas" =>
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
  #       {"name" => "Battery cycle count", "variable" => "batCycleCount", "value" => "2"}],
  def real_data
    response = post('/op/v1/device/real/query', { sns: [SERIAL_NUMBER] })
    response['result'].first['datas']
  end

  ##
  #  "result" =>
  #   [{"datas" =>
  #      [{"unit" => "℃", "data" => [{"time" => "2026-05-12 16:21:32 ACST+0930", "value" => 36.6}, {"time" => "2026-05-12 16:26:32 ACST+0930", "value" => 36.1}], "name" => "InvTemperation", "variable" => "invTemperation"},
  #       {"unit" => "℃", "data" => [{"time" => "2026-05-12 16:21:32 ACST+0930", "value" => 35.5}, {"time" => "2026-05-12 16:26:32 ACST+0930", "value" => 35.3}], "name" => "batTemperature", "variable" => "batTemperature"},
  #       {"unit" => "%", "data" => [{"time" => "2026-05-12 16:21:32 ACST+0930", "value" => 58.0}, {"time" => "2026-05-12 16:26:32 ACST+0930", "value" => 58.0}], "name" => "SoC", "variable" => "SoC"},
  #       {"unit" => "kW", "data" => [{"time" => "2026-05-12 16:21:32 ACST+0930", "value" => 0.216}, {"time" => "2026-05-12 16:26:32 ACST+0930", "value" => 0.223}], "name" => "Load Power", "variable" => "loadsPower"},
  #       {"unit" => "kW", "data" => [{"time" => "2026-05-12 16:21:32 ACST+0930", "value" => 0.036}, {"time" => "2026-05-12 16:26:32 ACST+0930", "value" => 0.033}], "name" => "Feed-in Power", "variable" => "feedinPower"},
  #       {"unit" => "kW",
  #        "data" => [{"time" => "2026-05-12 16:21:32 ACST+0930", "value" => 0.0}, {"time" => "2026-05-12 16:26:32 ACST+0930", "value" => 0.0}],
  #        "name" => "GridConsumption Power",
  #        "variable" => "gridConsumptionPower"},
  #       {"unit" => "kW", "data" => [{"time" => "2026-05-12 16:21:32 ACST+0930", "value" => 0.0}, {"time" => "2026-05-12 16:26:32 ACST+0930", "value" => 0.0}], "name" => "Charge Power", "variable" => "batChargePower"},
  #       {"unit" => "kW", "data" => [{"time" => "2026-05-12 16:21:32 ACST+0930", "value" => 0.0}, {"time" => "2026-05-12 16:26:32 ACST+0930", "value" => 0.093}], "name" => "Discharge Power", "variable" => "batDischargePower"}],
  #     "deviceSN" => "60KB103061FA061"}]}
  def historic_data(variables = [], timespan_s = DAY_IN_SECONDS)
    end_time = Time.now.to_i * 1000
    start_time = end_time - (timespan_s * 1000)

    params = {
      sn: SERIAL_NUMBER,
      begin: start_time,
      end: end_time,
    }
    params[:variables] = variables if variables.any?
    post('/op/v0/device/history/query', params)
  end

  def telemetry(timespan_s = DAY_IN_SECONDS)
    response = historic_data(VARIABLES.keys, timespan_s)
    data = response['result'].first['datas']
    telemetry = {}
    data.each do |datum|
      variable = VARIABLES[datum['variable']]
      datum['data'].each do |point|
        time = point['time']
        telemetry[time] = {} unless telemetry.key?(time)
        telemetry[time][variable] = point['value']
      end
    end
    telemetry
  end

  private

  def post(path, params = {})
    uri = URI("#{BASE_URL}#{path}")
    headers = generate_headers(path)

    request = Net::HTTP::Post.new(uri, headers)
    request.body = params.to_json unless params.empty?

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    handle_response(response)
  end

  def generate_headers(path)
    timestamp_ms = (Time.now.to_f * 1000).to_i.to_s
    signature_string = "#{path}\\r\\n#{ACCESS_TOKEN}\\r\\n#{timestamp_ms}"
    signature = Digest::MD5.hexdigest(signature_string.encode('utf-8'))

    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json',
      'token' => ACCESS_TOKEN,
      'signature' => signature,
      'timestamp' => timestamp_ms,
      'lang' => 'en',
    }
  end

  def handle_response(response)
    case response
    when Net::HTTPSuccess
      JSON.parse(response.body)
    else
      raise "HTTP error: #{response.code} #{response.message}"
    end
  end
end
