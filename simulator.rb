# Requirements
# - Hot water must be fully charged each day (let's say 20kWh)
# - Battery must be at least 60% for the night (By 9pm)
# - Free power between 11am and 2pm
# - Maximum grid draw is 14.5kW
# - Maximum grid export is 10.0kW
# - Maximum battery charge is 10.0kW
# - Solar yields: 15kWh/day Winter, 25kWh/day Spring/Autumn, 30kWh/day Summer, spread over daylight hours bell-curve
# - Humans use 15kWh/day
# - Bonus for exporting 6-9pm (15c/kWh) for the first 15kWh
# - $1/day for not exporting during 11am to 2pm
# - Exporting is 2c for all other times
# - Grid costs 55c/kWh to import for all other times
# - Score penalty for changing modes (favour simplicity)

require 'fiddle'
require 'pry-byebug'
require 'rb-readline'
Pry.config.input = STDIN
Pry.config.output = STDOUT


class Tick
  def self.at(hour: 0, minute: 0)
    hour * 60 + minute
  end

  def self.am(hour, minute = 0)
    hour * 60 + minute
  end

  def self.pm(hour, minute = 0)
    (hour + 12) * 60 + minute
  end
end

class Simulation
  # Variables
  SEASON = :winter
  MAX_BATTERY_KWH = 42.0
  MAX_HOT_WATER_KWH = 20.0
  MAX_GRID_IMPORT_KW = 14.5
  MAX_GRID_EXPORT_KW = 10.0
  MAX_BATTERY_CHARGE_KW = 10.0
  MAX_HOT_WATER_CHARGE_KW = 5.0
  HOT_WATER_LEAK_RATE = 0.05
  SOLAR_KWH_PER_DAY = {
    winter: 15.0,
    spring: 25.0,
    autumn: 25.0,
    summer: 30.0
  }
  SOLAR_PERIOD = (Tick::am(9)...Tick::pm(4)).freeze
  SOLAR_KW = SOLAR_KWH_PER_DAY[SEASON] / (SOLAR_PERIOD.size / 60)
  HUMAN_KWH_PER_DAY = 15.0
  HUMAN_HOT_WATER_KWH_PER_DAY = 20.0
  SERVICE_CHARGE = 1.55
  BONUS_SERVICE_REFUND = 1.00
  BONUS_SERVICE_REFUND_PERIOD = (Tick::am(11)...Tick::pm(2)).freeze
  GRID_BONUS_EXPORT_PER_KWH = 0.15
  GRID_BONUS_EXPORT_MAX_KWH = 15.0
  GRID_BONUS_EXPORT_PERIOD = (Tick::pm(6)...Tick::pm(9)).freeze
  FREE_POWER_PERIOD = (Tick::am(11)...Tick::pm(2)).freeze
  GRID_TARIFF = 0.55
  GRID_FEED_IN = 0.02

  attr_accessor :time, :mode, :state

  def initialize(time: 0)
    @time = time
    @state = State.new
    @mode = Mode.new(simulation: self, state: @state)
  end

  def run(minutes = 1440)
    minutes.times { step }
  end

  def step
    if @time % 1440 == 0
      @state.spend(Simulation::SERVICE_CHARGE)
      @state.reset_bonus
    end

    # Add $1 for not importing between 6pm and 9pm
    if @time == GRID_BONUS_EXPORT_PERIOD.end && @state.bonus_imported <= 0.005
      @state.earn(Simulation::BONUS_SERVICE_REFUND)
    end

    @mode.step

    @time += 1
  end

  # TODO: Curve over the period
  def solar
    return 0 if @time < SOLAR_PERIOD.begin || @time > SOLAR_PERIOD.end

    SOLAR_KW
  end

  # TODO: Curve over the day
  def load
    HUMAN_KWH_PER_DAY / 24.0
  end

  def import_price
    return 0 if free_power_period?
    GRID_TARIFF
  end

  def export_price
    return GRID_BONUS_EXPORT_PER_KWH if GRID_BONUS_EXPORT_PERIOD.cover?(@time)
    GRID_FEED_IN
  end

  def free_power_period?
    FREE_POWER_PERIOD.cover?(@time)
  end

  def bonus_export_period?
    GRID_BONUS_EXPORT_PERIOD.cover?(@time)
  end
end

class State
  attr_accessor :money, :battery_kwh, :hot_water_kwh, :bonus_imported, :bonus_exported

  def initialize(money: 0, battery_soc: 50, hot_water_soc: 50)
    @money = money
    @battery_kwh = battery_soc * Simulation::MAX_BATTERY_KWH / 100
    @hot_water_kwh = hot_water_soc * Simulation::MAX_HOT_WATER_KWH / 100
    @bonus_imported = 0
    @bonus_exported = 0
  end

  def reset_bonus
    @bonus_imported = 0
    @bonus_exported = 0
  end

  def battery_soc
    @battery_kwh * 100 / Simulation::MAX_BATTERY_KWH
  end

  def hot_water_soc
    @hot_water_kwh * 100 / Simulation::MAX_HOT_WATER_KWH
  end

  def spend(amount)
    @money -= amount
  end

  def earn(amount)
    @money += amount
  end

  def charge_battery(kW)
    amount = kW / 60.0

    actual = amount
    actual = amount / 2 if battery_soc > 90
    actual = amount / 4 if battery_soc > 95

    if @battery_kwh + actual > Simulation::MAX_BATTERY_KWH
      actual = Simulation::MAX_BATTERY_KWH - @battery_kwh
      @battery_kwh = Simulation::MAX_BATTERY_KWH
      return actual * 60.0
    end

    @battery_kwh += actual
    actual * 60.0
  end

  def discharge_battery(kW)
    amount = kW / 60.0

    if @battery_kwh < amount
      actual = @battery_kwh
      @battery_kwh = 0
      return actual * 60.0
    end

    @battery_kwh -= amount
    amount * 60.0
  end

  def charge_hot_water(kW)
    amount = kW / 60.0
    actual = amount
    actual = Simulation::MAX_HOT_WATER_KWH - @hot_water_kwh if @hot_water_kwh + amount > Simulation::MAX_HOT_WATER_KWH

    @hot_water_kwh += actual
    actual * 60.0
  end

  def discharge_hot_water(kW)
    amount = kW / 60.0
    actual = amount > @hot_water_kwh ? @hot_water_kwh : amount

    @hot_water_kwh -= actual
    actual * 60.0
  end

  def export_bonus(kW)
    amount = kW / 60.0
    @bonus_exported += amount
  end
end

class Mode
  # Battery modes
  FORCE_CHARGE = 'force_charge'
  FORCE_DISCHARGE = 'force_discharge'
  SELF_USE = 'self_use'
  FEED_IN = 'feed_in'

  # Hot water modes
  ON = 'on'
  OFF = 'off'

  attr_accessor :simulation, :state, :battery_mode, :hot_water_mode, :max_export, :max_import, :disable_soc

  def initialize(simulation:, state:, battery_mode: SELF_USE, hot_water_mode: ON, disable_soc: nil, max_export: Simulation::MAX_GRID_EXPORT_KW, max_import: Simulation::MAX_GRID_IMPORT_KW)
    @simulation = simulation
    @state = state
    @battery_mode = battery_mode
    @hot_water_mode = hot_water_mode
    @disable_soc = disable_soc
    @max_export = max_export
    @max_import = max_import
  end

  def step
    power_kw = 0
    power_kw += @simulation.solar
    power_kw -= @simulation.load

    if @hot_water_mode == ON
      power_kw -= state.charge_hot_water(Simulation::MAX_HOT_WATER_CHARGE_KW)
    end

    case battery_mode
    when SELF_USE
      if power_kw >= 0
        charged_kw = state.charge_battery(power_kw)
        power_kw -= charged_kw

        # Sell excess to grid
        if power_kw > 0
          sell_amount = [power_kw, max_export].min
          sell(sell_amount)
          power_kw -= sell_amount
        end
      else
        discharged_kw = state.discharge_battery(-power_kw)
        power_kw += discharged_kw

        # Buy remaining from grid
        if power_kw < 0
          buy_amount = [-power_kw, max_import].min
          buy(buy_amount)
          power_kw += buy_amount
        end
      end
    when FORCE_CHARGE
      battery_feed_kw = [@max_import - power_kw, Simulation::MAX_BATTERY_CHARGE_KW].min

      charged_kw = state.charge_battery(battery_feed_kw)
      power_kw -= charged_kw

      grid_draw = [-power_kw, @max_import].min

      if grid_draw > 0
        buy(grid_draw)
        power_kw += grid_draw
      else
        sell(-grid_draw)
        power_kw += grid_draw
      end
    when FORCE_DISCHARGE
      max_discharge = [state.battery_kwh, Simulation::MAX_BATTERY_CHARGE_KW].min
      feed_in = [power_kw + max_discharge, @max_export].min

      if feed_in > 0
        sell(feed_in)
        power_kw -= feed_in
      else
        buy(-feed_in)
        power_kw += -feed_in
      end

      discharged_kw = state.discharge_battery(-power_kw)
      power_kw += discharged_kw
    when FEED_IN
      if power_kw >= 0
        sell_amount = [power_kw, max_export].min
        sell(sell_amount)
        power_kw -= sell_amount
      else
        discharged_kw = state.discharge_battery(-power_kw)
        power_kw += discharged_kw

        # Buy remaining from grid
        if power_kw < 0
          buy_amount = [-power_kw, max_import].min
          buy(buy_amount)
          power_kw += buy_amount
        end
      end
    end

    power_kw = 0 if power_kw > -0.0001 && power_kw < 0.0001
    byebug if power_kw != 0

    raise "Inverter exploded: #{power_kw} too many kW" if power_kw > 0
    raise "Blackout: #{power_kw} too few kW" if power_kw < 0

    # Leak a bit of hot water charge
    state.discharge_hot_water(Simulation::HOT_WATER_LEAK_RATE)
  end

  def buy(kW)
    amount = kW / 60.0
    price = @simulation.import_price * amount
    @state.bonus_imported += amount if @simulation.bonus_export_period?
    @state.spend(price)
  end

  def sell(kW)
    amount = kW / 60.0
    power = amount

    if @simulation.bonus_export_period? && @state.bonus_exported < Simulation::GRID_BONUS_EXPORT_MAX_KWH
      bonus_remaining = Simulation::GRID_BONUS_EXPORT_MAX_KWH - @state.bonus_exported
      bonus_amount = [power, bonus_remaining].min
      @state.export_bonus(bonus_amount * 60)
      @state.earn(bonus_amount * Simulation::GRID_BONUS_EXPORT_PER_KWH)
      power -= bonus_amount
    end

    @state.earn(power * Simulation::GRID_FEED_IN) if power > 0
  end
end

class Plan < Mode
  attr_accessor :modes, :periods, :default_mode

  def initialize(simulation:, state:, default_mode: Mode::SELF_USE)
    @modes = []
    @periods = {}
    @simulation = simulation
    @state = state
    @default_mode = default_mode
  end

  def add_mode(mode, period)
    @modes << mode
    @periods[period] = mode
  end

  def step
    current_mode = mode(@simulation.time)
    case current_mode.battery_mode
    when Mode::FORCE_CHARGE
      current_mode = @default_mode if @state.battery_soc >= (current_mode.disable_soc || 100)
    when Mode::FORCE_DISCHARGE
      current_mode = @default_mode if @state.battery_soc <= (current_mode.disable_soc || 0)
    end
    set_mode(current_mode)

    super
  end

  private

  def mode(time)
    @periods.each do |period, mode|
      return mode if period.cover?(time)
    end
    @default_mode
  end

  def set_mode(mode)
    @battery_mode = mode.battery_mode
    @hot_water_mode = mode.hot_water_mode
    @max_export = mode.max_export
    @max_import = mode.max_import
    @disable_soc = mode.disable_soc
  end
end

simulation = Simulation.new

default_mode = Mode.new(simulation: simulation, state: simulation.state, battery_mode: Mode::SELF_USE, hot_water_mode: Mode::OFF)
plan = Plan.new(simulation: simulation, state: simulation.state, default_mode: default_mode)
plan.add_mode(Mode.new(simulation: simulation, state: simulation.state, battery_mode: Mode::FORCE_DISCHARGE, hot_water_mode: Mode::OFF, disable_soc: 20), (Tick::am(10)...Tick::am(11)))
plan.add_mode(Mode.new(simulation: simulation, state: simulation.state, battery_mode: Mode::FORCE_CHARGE, hot_water_mode: Mode::ON, disable_soc: 100), (Tick::am(11)...Tick::pm(2)))
plan.add_mode(Mode.new(simulation: simulation, state: simulation.state, battery_mode: Mode::FEED_IN, hot_water_mode: Mode::ON), (Tick::pm(2)...Tick::pm(4)))
plan.add_mode(Mode.new(simulation: simulation, state: simulation.state, battery_mode: Mode::FORCE_DISCHARGE, hot_water_mode: Mode::OFF, disable_soc: 50), (Tick::pm(6)...Tick::pm(9)))
simulation.mode = plan

require 'csv'
CSV.open('output.csv', 'w') do |csv|
  csv << ['Time', 'Money', 'Battery', 'Hot Water']

  1440.times do
    simulation.step
    puts simulation.state.inspect
    csv << [simulation.time, simulation.state.money, simulation.state.battery_kwh, simulation.state.hot_water_kwh]
  end
end
