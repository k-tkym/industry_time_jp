# frozen_string_literal: true

require 'time'
require_relative 'industry_time/version'

module IndustryTime
  class << self
    # Global threshold hour for converting back to industry format.
    # Default is 4 (meaning times from 00:00:00 to 03:59:59 will be formatted as 24:00:00 to 27:59:59).
    attr_accessor :threshold_hour

    # Pre-processes a string to convert 24+ hours to standard hours and returns the number of days to add.
    # Returns [modified_string, days_to_add] if a 24+ hour time was matched and modified.
    # Returns nil if no modification is necessary.
    def pre_process_parse(str)
      return nil unless str.is_a?(String)

      # Match the time component: hours (>=24), minutes, optional seconds/subseconds
      # Prevent matching timezone offsets like +09:00 or -05:00
      match = str.match(/(?<![-+\d])(\d{2,}):(\d{2})(?::(\d{2}))?(?:\.(\d+))?/)
      return nil unless match

      hour = match[1].to_i
      return nil if hour < 24

      days_to_add = hour / 24
      new_hour = hour % 24

      new_str = str.dup
      new_str[match.begin(1)...match.end(1)] = format('%02d', new_hour)

      [new_str, days_to_add]
    end

    # Formats a Time object into an industry time format.
    def format_time(time, format, threshold_hour)
      if time.hour < threshold_hour
        shifted_time = time - 86_400
        industry_hour = time.hour + 24

        h_val = format('%02d', industry_hour)
        k_val = format('%2d', industry_hour)

        modified_format = replace_hour_placeholders(format, h_val, k_val)
        shifted_time.strftime(modified_format)
      else
        time.strftime(format)
      end
    end

    # Apply global monkey patches to Time class.
    def patch!
      return if @patched

      @patched = true

      ::Time.singleton_class.prepend(TimeClassExtension)
      ::Time.include(TimeExtension)
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
        parsed + (days_to_add * 86_400)
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

  # Refinements for scoping the changes
  refine ::Time.singleton_class do
    def parse(str, ...)
      processed = IndustryTime.pre_process_parse(str)
      if processed
        new_str, days_to_add = processed
        parsed = super(new_str, ...)
        parsed + (days_to_add * 86_400)
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
end
