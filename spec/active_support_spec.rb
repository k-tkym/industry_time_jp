# frozen_string_literal: true

require 'spec_helper'

begin
  require 'active_support/all'
rescue LoadError
  # ActiveSupport is not available, skip tests
end

if defined?(ActiveSupport)
  RSpec.describe 'ActiveSupport Integration' do
    before(:all) do
      IndustryTime.patch!
      # Set timezone to JST for testing
      Time.zone = 'Tokyo'
    end

    after(:all) do
      Time.zone = nil
    end

    describe 'Time.zone.parse' do
      it 'parses 24+ hour time and adds a day' do
        time = Time.zone.parse('2026-06-12 25:30:00')
        expect(time.year).to eq(2026)
        expect(time.month).to eq(6)
        expect(time.day).to eq(13)
        expect(time.hour).to eq(1)
        expect(time.min).to eq(30)
      end

      it 'returns nil for invalid time strings' do
        expect(Time.zone.parse('invalid')).to be_nil
      end

      it 'parses normal time without shifting' do
        time = Time.zone.parse('2026-06-12 10:00:00')
        expect(time.day).to eq(12)
        expect(time.hour).to eq(10)
      end
    end

    describe 'ActiveSupport::TimeWithZone#to_industry_format' do
      it 'formats early morning times back to 24+ format' do
        time = Time.zone.parse('2026-06-13 01:30:00')
        expect(time.to_industry_format).to eq('2026-06-12 25:30:00')
      end

      it 'formats normal times unchanged' do
        time = Time.zone.parse('2026-06-12 10:00:00')
        expect(time.to_industry_format).to eq('2026-06-12 10:00:00')
      end
    end
  end
end
