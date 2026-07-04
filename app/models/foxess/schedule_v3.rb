# frozen_string_literal: true

module Foxess
  class ScheduleV3
    class Group
      attr_accessor :enabled, :start_hour, :start_minute, :end_hour, :end_minute, :work_mode, :extra_param

      def initialize(enabled: 1, start_hour: 0, start_minute: 0, end_hour: 23, end_minute: 59, work_mode: 'SelfUse', extra_param: ExtraParam.new)
        @enabled = enabled
        @start_hour = start_hour
        @start_minute = start_minute
        @end_hour = end_hour
        @end_minute = end_minute
        @work_mode = work_mode
        @extra_param = extra_param
      end

      def self.from_json(group)
        Group.new(
          start_hour: group['startHour'],
          start_minute: group['startMinute'],
          end_hour: group['endHour'],
          end_minute: group['endMinute'],
          work_mode: group['workMode'],
          extra_param: ExtraParam.from_json(group['extraParam'])
        )
      end

      def to_h
        {
          'enable' => @enabled,
          'startHour' => @start_hour,
          'startMinute' => @start_minute,
          'endHour' => @end_hour,
          'endMinute' => @end_minute,
          'workMode' => @work_mode,
          'extraParam' => @extra_param.to_h
        }
      end

      def to_json
        to_h.to_json
      end

      def default?
        enabled == 1 && start_hour == 0 && start_minute == 0 && end_hour == 23 && end_minute == 59
      end

      def extend_by(minutes)
        @end_minute += minutes
        if @end_minute >= 60
          @end_minute = 0
          @end_hour += 1
        end
        if @end_hour >= 24
          @end_hour = 23
          @end_minute = 59
        end
      end
    end

    class ExtraParam
      attr_accessor :fd_pwr, :min_soc_on_grid, :pv_limit, :reactive_power, :export_limit, :fd_soc, :import_limit, :max_soc

      def initialize(fd_pwr: 10500.0, min_soc_on_grid: 10.0, pv_limit: 20000.0, reactive_power: 0.0, export_limit: 10000.0, fd_soc: 10.0, import_limit: 14500.0, max_soc: 100.0)
        @fd_pwr = fd_pwr
        @min_soc_on_grid = min_soc_on_grid
        @pv_limit = pv_limit
        @reactive_power = reactive_power
        @export_limit = export_limit
        @fd_soc = fd_soc
        @import_limit = import_limit
        @max_soc = max_soc
      end

      def self.from_json(extra_param)
        ExtraParam.new(
          fd_pwr: extra_param['fdPwr'],
          min_soc_on_grid: extra_param['minSocOnGrid'],
          pv_limit: extra_param['pvLimit'],
          reactive_power: extra_param['reactivePower'],
          export_limit: extra_param['exportLimit'],
          fd_soc: extra_param['fdSoc'],
          import_limit: extra_param['importLimit'],
          max_soc: extra_param['maxSoc']
        )
      end

      def to_h
        {
          'fdPwr' => @fd_pwr,
          'minSocOnGrid' => @min_soc_on_grid,
          'pvLimit' => @pv_limit,
          'reactivePower' => @reactive_power,
          'exportLimit' => @export_limit,
          'fdSoc' => @fd_soc,
          'importLimit' => @import_limit,
          'maxSoc' => @max_soc
        }
      end

      def to_json
        to_h.to_json
      end
    end

    attr_accessor :groups, :default_mode

    def initialize(response)
      raise "Unknown response: #{response}" unless response['msg'] == 'Operation successful'

      @groups = []
      response['result']['groups'].each do |group_json|
        group = Group.from_json(group_json)
        if group.default?
          @default_mode = group.work_mode
        else
          @groups << group
        end
      end
    end

    def groups
      groups = []
      @groups.each do |group|
        groups << group.to_h
      end
      groups << Group.new(work_mode: @default_mode).to_h
      groups
    end

    def action_at(hour:, minute:)
      @groups.find do |group|
        next if hour == group.start_hour && minute < group.start_minute
        next if hour == group.end_hour && minute > group.end_minute
        hour >= group.start_hour && hour <= group.end_hour
      end || Group.new(work_mode: @default_mode)
    end
  end
end
