# frozen_string_literal: true

require 'time'
require 'date'
require_relative 'industry_time/version'

module IndustryTime
  class << self
    # Global threshold hour for converting back to industry format.
    # Default is 4 (meaning times from 00:00:00 to 03:59:59 will be formatted as 24:00:00 to 27:59:59).
    attr_accessor :threshold_hour

    # Safely shifts a time object by a given number of days, respecting DST.
    def shift_days(time, days)
      return time if days.zero?

      if defined?(::ActiveSupport::TimeWithZone) && time.is_a?(::ActiveSupport::TimeWithZone)
        time + days.days
      elsif defined?(::DateTime) && time.is_a?(::DateTime)
        time + days
      elsif time.utc? || time.zone.nil?
        time + (days * 86_400)
      else
        d = time.to_date + days
        ::Time.local(d.year, d.month, d.day, time.hour, time.min, time.sec + time.subsec)
      end
    end

    # Pre-processes a string to convert 24+ hours to standard hours and returns the number of days to add.
    # Replaces all occurrences using gsub.
    def pre_process_parse(str)
      return nil unless str.is_a?(String)

      max_days_to_add = 0
      modified = false

      new_str = str.gsub(/(?<![-+\d])(\d{2,}):(\d{2})(?::(\d{2}))?(?:\.(\d+))?/) do |match|
        hour = ::Regexp.last_match(1).to_i
        if hour >= 24
          days = hour / 24
          max_days_to_add = days if days > max_days_to_add
          modified = true
          format('%<hour>02d:%<rest>s', hour: hour % 24, rest: match.split(':', 2)[1])
        else
          match
        end
      end

      modified ? [new_str, max_days_to_add] : nil
    end

    # Formats a Time object into an industry time format.
    def format_time(time, format, threshold_hour)
      if time.hour < threshold_hour
        shifted_time = shift_days(time, -1)
        industry_hour = time.hour + 24

        h_val = format('%02d', industry_hour)
        k_val = format('%2d', industry_hour)

        modified_format = replace_hour_placeholders(format, h_val, k_val)
        shifted_time.strftime(modified_format)
      else
        time.strftime(format)
      end
    end

    # Apply global monkey patches to Time, DateTime and ActiveSupport classes.
    def patch!
      return if @patched

      @patched = true

      ::Time.singleton_class.prepend(TimeClassExtension)
      ::Time.include(TimeExtension)

      if defined?(::DateTime)
        ::DateTime.singleton_class.prepend(DateTimeClassExtension)
        ::DateTime.include(TimeExtension)
      end

      return unless defined?(::ActiveSupport)

      ::ActiveSupport::TimeZone.prepend(ActiveSupportTimeZoneExtension) if defined?(::ActiveSupport::TimeZone)
      return unless defined?(::ActiveSupport::TimeWithZone)

      ::ActiveSupport::TimeWithZone.include(TimeExtension)
    end

    private

    # Safely replaces %H and %k in a strftime format string, respecting double percent (%%) escapes.
    def replace_hour_placeholders(format_str, h_val, k_val)
      parts = format_str.split('%%', -1)
      parts.map! do |part|
        part.gsub(/(?<!%)%([-_0^#\d]*)H/) { h_val }
            .gsub(/(?<!%)%([-_0^#\d]*)k/) { k_val }
      end
      parts.join('%%')
    end
  end

  # Default configuration
  self.threshold_hour = 4

  # Extension modules for monkey patches
  module TimeClassExtension
    def parse(str, ...)
      processed = IndustryTime.pre_process_parse(str)
      if processed
        new_str, days_to_add = processed
        parsed = super(new_str, ...)
        IndustryTime.shift_days(parsed, days_to_add)
      else
        super
      end
    end

    def strptime(str, format, ...)
      processed = IndustryTime.pre_process_parse(str)
      if processed
        new_str, days_to_add = processed
        parsed = super(new_str, format, ...)
        IndustryTime.shift_days(parsed, days_to_add)
      else
        super
      end
    end
  end

  module DateTimeClassExtension
    def parse(str, ...)
      processed = IndustryTime.pre_process_parse(str)
      if processed
        new_str, days_to_add = processed
        parsed = super(new_str, ...)
        IndustryTime.shift_days(parsed, days_to_add)
      else
        super
      end
    end

    def strptime(str, format, ...)
      processed = IndustryTime.pre_process_parse(str)
      if processed
        new_str, days_to_add = processed
        parsed = super(new_str, format, ...)
        IndustryTime.shift_days(parsed, days_to_add)
      else
        super
      end
    end
  end

  module TimeExtension
    def to_industry_format(format = '%Y-%m-%d %H:%M:%S', threshold_hour: IndustryTime.threshold_hour)
      IndustryTime.format_time(self, format, threshold_hour)
    end
  end

  module ActiveSupportTimeZoneExtension
    def parse(str, ...)
      processed = IndustryTime.pre_process_parse(str)
      if processed
        new_str, days_to_add = processed
        parsed = super(new_str, ...)
        parsed ? IndustryTime.shift_days(parsed, days_to_add) : nil
      else
        super
      end
    end
  end

  # Refinements for scoping the changes
  refine ::Time.singleton_class do
    def parse(str, ...)
      processed = IndustryTime.pre_process_parse(str)
      if processed
        new_str, days_to_add = processed
        parsed = super(new_str, ...)
        IndustryTime.shift_days(parsed, days_to_add)
      else
        super
      end
    end

    def strptime(str, format, ...)
      processed = IndustryTime.pre_process_parse(str)
      if processed
        new_str, days_to_add = processed
        parsed = super(new_str, format, ...)
        IndustryTime.shift_days(parsed, days_to_add)
      else
        super
      end
    end
  end

  refine ::Time do
    def to_industry_format(format = '%Y-%m-%d %H:%M:%S', threshold_hour: IndustryTime.threshold_hour)
      IndustryTime.format_time(self, format, threshold_hour)
    end
  end

  if defined?(::DateTime)
    refine ::DateTime.singleton_class do
      def parse(str, ...)
        processed = IndustryTime.pre_process_parse(str)
        if processed
          new_str, days_to_add = processed
          parsed = super(new_str, ...)
          IndustryTime.shift_days(parsed, days_to_add)
        else
          super
        end
      end

      def strptime(str, format, ...)
        processed = IndustryTime.pre_process_parse(str)
        if processed
          new_str, days_to_add = processed
          parsed = super(new_str, format, ...)
          IndustryTime.shift_days(parsed, days_to_add)
        else
          super
        end
      end
    end

    refine ::DateTime do
      def to_industry_format(format = '%Y-%m-%d %H:%M:%S', threshold_hour: IndustryTime.threshold_hour)
        IndustryTime.format_time(self, format, threshold_hour)
      end
    end
  end
end

require_relative 'industry_time/railtie' if defined?(Rails::Railtie)
