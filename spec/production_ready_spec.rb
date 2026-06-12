# frozen_string_literal: true

require 'spec_helper'
require 'date'

RSpec.describe 'Production Ready Fixes' do
  before(:all) do
    IndustryTime.patch!
  end

  describe 'Time.strptime' do
    it 'parses 24+ hour designations with explicit format' do
      time = Time.strptime('2026-06-12 25:30:00', '%Y-%m-%d %H:%M:%S')
      expect(time.year).to eq(2026)
      expect(time.month).to eq(6)
      expect(time.day).to eq(13)
      expect(time.hour).to eq(1)
      expect(time.min).to eq(30)
    end
  end

  describe 'DateTime integration' do
    it 'parses 24+ hour designations' do
      dt = DateTime.parse('2026-06-12 25:30:00')
      expect(dt.year).to eq(2026)
      expect(dt.month).to eq(6)
      expect(dt.day).to eq(13)
      expect(dt.hour).to eq(1)
      expect(dt.min).to eq(30)
    end

    it 'supports strptime' do
      dt = DateTime.strptime('2026-06-12 25:30:00', '%Y-%m-%d %H:%M:%S')
      expect(dt.day).to eq(13)
      expect(dt.hour).to eq(1)
    end

    it 'formats back to industry time' do
      dt = DateTime.parse('2026-06-13 01:30:00')
      expect(dt.to_industry_format).to eq('2026-06-12 25:30:00')
    end
  end

  describe 'DST boundaries (America/New_York fallback)' do
    before do
      @original_tz = ENV.fetch('TZ', nil)
      ENV['TZ'] = 'America/New_York'
    end

    after do
      ENV['TZ'] = @original_tz
    end

    it 'correctly parses 25:00 on the day before fallback' do
      # In 2023, Nov 5 is fallback day.
      # If we parse 25:00 on Nov 4, it should mean Nov 5, 01:00 AM.
      time = Time.parse('2023-11-04 25:00:00')
      expect(time.year).to eq(2023)
      expect(time.month).to eq(11)
      expect(time.day).to eq(5)
      expect(time.hour).to eq(1)
      expect(time.min).to eq(0)
    end

    it 'correctly formats 01:00 on the fallback day back to 25:00 of previous day' do
      time = Time.local(2023, 11, 5, 1, 0, 0)
      expect(time.to_industry_format).to eq('2023-11-04 25:00:00')
    end
  end

  describe 'Multiple occurrences replacement' do
    it 'replaces all 24+ hour instances in a string' do
      # Example: A custom format containing two times.
      # Actually, Time.parse might not parse this, but let's test strptime or pre_process_parse directly.
      str = 'Start: 25:30, End: 28:45'
      processed, days = IndustryTime.pre_process_parse(str)
      expect(processed).to eq('Start: 01:30, End: 04:45')
      expect(days).to eq(1)
    end
  end
end
