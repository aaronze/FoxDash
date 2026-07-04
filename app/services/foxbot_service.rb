# frozen_string_literal: true

require_relative 'telegram_service'
require 'models/foxess/real_data_v1'
require 'models/foxess/schedule_v3'

class Plan
  attr_reader :actions, :default_action

  def initialize(actions: [])
    @actions = actions
    @default_action = Action.new(work_mode: 'SelfUse')
  end

  def add_action(action)
    @actions << action
  end

  def set_default_action(work_mode)
    @default_mode = Action.new(work_mode:)
  end

  def action_at(hour:, minute:, soc:)
    action = @actions.find do |action|
      next unless action.minimum_soc <= soc && soc <= action.maximum_soc
      next if hour == action.start_hour && minute < action.start_minute
      next if hour == action.end_hour && minute > action.end_minute
      hour >= action.start_hour && hour <= action.end_hour
    end
    return action if action

    @default_action
  end

  def current_action(soc:)
    time = Time.now
    action_at(hour: time.hour, minute: time.min, soc:)
  end
end

class Action
  attr_reader :work_mode, :start_hour, :start_minute, :end_hour, :end_minute, :minimum_soc, :maximum_soc, :direction

  WORK_MODES = [
    'SelfUse',
    'ForceCharge',
    'ForceDischarge',
    'Feedin'
  ]

  DIRECTION_LEFT = 'left'
  DIRECTION_RIGHT = 'right'

  def initialize(work_mode: 'SelfUse', start_hour: 0, start_minute: 0, end_hour: 23, end_minute: 59, minimum_soc: 10.0, maximum_soc: 100.0, direction: DIRECTION_RIGHT)
    @work_mode = work_mode
    @start_hour = start_hour
    @start_minute = start_minute
    @end_hour = end_hour
    @end_minute = end_minute
    @minimum_soc = minimum_soc
    @maximum_soc = maximum_soc
    @direction = direction
  end
end

class HourMinute
  attr_accessor :hour, :minute

  def initialize(hour:, minute:)
    @hour = hour
    @minute = minute
  end

  def add(minutes)
    @minute += minutes

    while @minute >= 60
      @hour += 1
      @minute -= 60
    end
    while @hour >= 24
      @hour -= 24
    end
  end
end

class FoxbotService
  attr_reader :foxess_service, :plan

  MAX_CHARGE = 42.0
  DISCHARGE_KW = 10.0
  CHARGE_KW = 10.0
  DAILY_LOAD_KWH = 35.0
  DAILY_SOLAR_KWH = 12.0

  def initialize(foxess_service:)
    @foxess_service = foxess_service
  end

  def chunk(array)
    counts = []
    array.each do |item|
      if counts.count > 0 && counts.last[0] == item
        counts.last[1] += 1
      else
        counts << [item, 1]
      end
    end
    counts.map { |count| "#{count[0]} x#{count[1]}" }
  end

  def run
    directives = TelegramService.directives
    @plan = Plan.new
    @plan.add_action(Action.new(work_mode: 'ForceDischarge', start_hour: 9, start_minute: 30, end_hour: 10, end_minute: 59, minimum_soc: 35.0, direction: Action::DIRECTION_LEFT)) unless directives.include?(TelegramService::DIRECTIVE_SKIP_SELL)
    @plan.add_action(Action.new(work_mode: 'Feedin', start_hour: 9, start_minute: 1, end_hour: 11, end_minute: 0, minimum_soc: 20.0)) unless directives.include?(TelegramService::DIRECTIVE_SKIP_SELL)
    @plan.add_action(Action.new(work_mode: 'ForceCharge', start_hour: 11, start_minute: 1, end_hour: 13, end_minute: 58, maximum_soc: 95.0)) unless directives.include?(TelegramService::DIRECTIVE_SKIP_BUY)
    @plan.add_action(Action.new(work_mode: 'Feedin', start_hour: 11, start_minute: 1, end_hour: 16, end_minute: 59, minimum_soc: 90.0)) unless directives.include?(TelegramService::DIRECTIVE_SKIP_SELL)
    @plan.add_action(Action.new(work_mode: 'ForceDischarge', start_hour: 18, start_minute: 1, end_hour: 19, end_minute: 31, minimum_soc: 60.0, direction: Action::DIRECTION_LEFT)) unless directives.include?(TelegramService::DIRECTIVE_SKIP_SELL)

    # Fetch the current schedule
    schedule = Foxess::ScheduleV3.new(foxess_service.get_schedule)

    # Fetch the current status
    real_data = Foxess::RealDataV1.new(foxess_service.real_data)

    time = HourMinute.new(hour: Time.now.hour, minute: Time.now.min)
    time.minute = time.minute - (time.minute % 5) + 1

    actions = []
    scheduled = []
    charge = MAX_CHARGE * real_data.soc / 100.0
    288.times do |i|
      action = @plan.action_at(hour: time.hour, minute: time.minute, soc: charge * 100.0 / MAX_CHARGE)
      actions << action
      scheduled << schedule.action_at(hour: time.hour, minute: time.minute)

      time.add(5)

      case action.work_mode
      when 'ForceDischarge'
        charge -= DISCHARGE_KW / 12.0
        charge = 4.0 if charge < 4.0
      when 'ForceCharge'
        charge += CHARGE_KW / 12.0
        charge = 40.0 if charge > 40.0
      end
      charge -= DAILY_LOAD_KWH / 24.0 / 12.0
      charge += DAILY_SOLAR_KWH / 24.0 / 12.0
    end

    puts "Actions: #{chunk(actions.map { |a| a.work_mode }).inspect}"
    puts "Scheduled: #{chunk(scheduled.map { |s| s.work_mode }).inspect}"

    # Only modify the schedule if they differ
    if actions.map(&:work_mode) == scheduled.map(&:work_mode)
      puts "No changes needed"
      return
    end

    # Only modify if different NOW or significantly different
    if actions.first.work_mode == scheduled.first.work_mode
      differences = 0
      actions.each_with_index do |action, i|
        differences += 1 if action.work_mode != scheduled[i].work_mode
      end
      if differences < 10
        puts "Not enough future changes needed"
        return
      end
    end

    # Execute action
    groups = []
    time = HourMinute.new(hour: Time.now.hour, minute: Time.now.min)
    time.minute = time.minute - (time.minute % 5) + 1
    actions.each do |action|
      if groups.count > 0 && groups.last.work_mode == action.work_mode && groups.last.end_hour <= time.hour
        groups.last.extend_by(5)
        if (groups.last.end_hour == action.end_hour && groups.last.end_minute > action.end_minute) || groups.last.end_hour > action.end_hour
          groups.last.end_hour = action.end_hour
          groups.last.end_minute = action.end_minute
        end
      else
        group = Foxess::ScheduleV3::Group.new(
          work_mode: action.work_mode,
          start_hour: time.hour,
          start_minute: time.minute,
          end_hour: time.hour,
          end_minute: time.minute
        )
        group.extend_by(5)
        groups << group unless group.default?
      end
      time.add(5)
    end

    groups.sort_by! { |group| group.start_hour*60 + group.start_minute  }
    groups = groups.each_with_object([]) do |group, combined|
      if combined.count == 0
        combined << group
        next
      end

      last_end_time = combined.last.end_hour*60 + combined.last.end_minute
      group_start_time = group.start_hour*60 + group.start_minute
      if combined.last.work_mode == group.work_mode && group_start_time - last_end_time <= 4
        combined.last.end_hour = group.end_hour
        combined.last.end_minute = group.end_minute
      else
        combined << group
      end
    end

    # Let default handle SelfUse
    groups.reject! { |group| group.work_mode == 'SelfUse' }
    groups << Foxess::ScheduleV3::Group.new(work_mode: 'SelfUse')

    response = foxess_service.set_schedule(groups: groups.map { |group| group.to_h })
    if response['result'].nil?
      puts "Failed to set schedule: #{response['msg']}"
      TelegramService.send_message("Failed to set schedule: #{response['msg']}", silent: true)
    end

    description = "Schedule updated:\n"
    groups.each do |group|
      if group.default?
        description += " - Chilling with #{group.work_mode} otherwise\n"
      else
        start_time = "#{group.start_hour}:#{group.start_minute.to_s.rjust(2, '0')}"
        end_time = "#{group.end_hour}:#{group.end_minute.to_s.rjust(2, '0')}"

        case group.work_mode
        when 'ForceCharge'
          description += " - Charging from #{start_time} to #{end_time}\n"
        when 'ForceDischarge'
          description += " - Selling from #{start_time} to #{end_time}\n"
        when 'Feedin'
          description += " - Selling excess power from #{start_time} to #{end_time}\n"
        else
          description += " - #{group.work_mode} from #{start_time} to #{end_time}\n"
        end
      end
    end

    TelegramService.send_message(description, silent: true)
  end
end