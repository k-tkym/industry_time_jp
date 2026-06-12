# frozen_string_literal: true

require "spec_helper"

# Define a module that uses the refinement to test it in isolation
module RefinementTester
  using IndustryTime

  def self.parse(str, *args)
    Time.parse(str, *args)
  end

  def self.to_industry_format(time, *args, **kwargs)
    time.to_industry_format(*args, **kwargs)
  end

  def self.respond_to_to_industry_format?(time)
    time.respond_to?(:to_industry_format)
  end
end

RSpec.describe IndustryTime do
  describe "Refinements (using IndustryTime)" do
    describe "Time.parse" do
      it "parses 24+ hour times correctly" do
        time = RefinementTester.parse("2026-06-12 25:30:00")
        expect(time.year).to eq(2026)
        expect(time.month).to eq(6)
        expect(time.day).to eq(13)
        expect(time.hour).to eq(1)
        expect(time.min).to eq(30)
        expect(time.sec).to eq(0)
      end

      it "parses 28:00:00 (without date) correctly relative to today" do
        time = RefinementTester.parse("28:00:00")
        expected_base = Time.now + 86400
        expect(time.year).to eq(expected_base.year)
        expect(time.month).to eq(expected_base.month)
        expect(time.day).to eq(expected_base.day)
        expect(time.hour).to eq(4)
        expect(time.min).to eq(0)
        expect(time.sec).to eq(0)
      end

      it "parses multi-day industry times (e.g. 49:15:00) correctly" do
        time = RefinementTester.parse("2026-06-12 49:15:00")
        expect(time.year).to eq(2026)
        expect(time.month).to eq(6)
        # 49 hours = 2 days (48 hours) + 1 hour. So it adds 2 days.
        expect(time.day).to eq(14)
        expect(time.hour).to eq(1)
        expect(time.min).to eq(15)
      end

      it "does not alter standard ISO 8601 or normal 24h formats" do
        standard_str = "2026-06-12T15:30:00+09:00"
        expect(RefinementTester.parse(standard_str)).to eq(Time.parse(standard_str))
      end

      it "raises ArgumentError for invalid date/time strings" do
        expect { RefinementTester.parse("invalid-string") }.to raise_error(ArgumentError)
      end
    end

    describe "Time#to_industry_format" do
      let(:base_time) { Time.parse("2026-06-13 01:30:45") }

      it "converts early morning times to the previous day industry time" do
        formatted = RefinementTester.to_industry_format(base_time)
        expect(formatted).to eq("2026-06-12 25:30:45")
      end

      it "respects a custom format string" do
        formatted = RefinementTester.to_industry_format(base_time, "%Y/%m/%d %H:%M")
        expect(formatted).to eq("2026/06/12 25:30")
      end

      it "does not modify times at or after the threshold hour" do
        daytime = Time.parse("2026-06-13 12:00:00")
        expect(RefinementTester.to_industry_format(daytime)).to eq("2026-06-13 12:00:00")
      end

      it "uses configured threshold_hour by default" do
        t_before = Time.parse("2026-06-13 03:59:59")
        t_after = Time.parse("2026-06-13 04:00:00")
        
        expect(RefinementTester.to_industry_format(t_before)).to eq("2026-06-12 27:59:59")
        expect(RefinementTester.to_industry_format(t_after)).to eq("2026-06-13 04:00:00")
      end

      it "respects per-call threshold_hour overrides" do
        t1 = Time.parse("2026-06-13 01:30:00")
        t2 = Time.parse("2026-06-13 02:30:00")
        
        expect(RefinementTester.to_industry_format(t1, threshold_hour: 2)).to eq("2026-06-12 25:30:00")
        expect(RefinementTester.to_industry_format(t2, threshold_hour: 2)).to eq("2026-06-13 02:30:00")
      end

      it "handles space-padded hour placeholder %k correctly" do
        t = Time.parse("2026-06-13 01:05:00")
        formatted = RefinementTester.to_industry_format(t, "%Y-%m-%d %k:%M")
        expect(formatted).to eq("2026-06-12 25:05")
      end

      it "ignores escaped percent signs %%H and %%k" do
        formatted = RefinementTester.to_industry_format(base_time, "%%H %%k %H:%M")
        expect(formatted).to eq("%H %k 25:30")
      end
    end
  end

  describe "Monkey Patches (global)" do
    before(:all) do
      # Prior to global patching, standard Time.parse does not handle 25h,
      # and global instances do not respond to to_industry_format.
      expect { Time.parse("2026-06-12 25:30:00") }.to raise_error(ArgumentError)
      expect(Time.now.respond_to?(:to_industry_format)).to be false

      # Apply global patch
      IndustryTime.patch!
    end

    it "enables to_industry_format globally on all Time instances" do
      expect(Time.now.respond_to?(:to_industry_format)).to be true
      t = Time.parse("2026-06-13 01:30:00")
      expect(t.to_industry_format).to eq("2026-06-12 25:30:00")
    end

    it "extends Time.parse globally to parse 24+ hour designations" do
      time = Time.parse("2026-06-12 26:15:00")
      expect(time.year).to eq(2026)
      expect(time.month).to eq(6)
      expect(time.day).to eq(13)
      expect(time.hour).to eq(2)
      expect(time.min).to eq(15)
    end

    it "respects global threshold_hour change" do
      old_threshold = IndustryTime.threshold_hour
      begin
        IndustryTime.threshold_hour = 5
        t = Time.parse("2026-06-13 04:30:00")
        expect(t.to_industry_format).to eq("2026-06-12 28:30:00")
      ensure
        IndustryTime.threshold_hour = old_threshold
      end
    end
  end
end
