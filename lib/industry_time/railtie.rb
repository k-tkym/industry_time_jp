# frozen_string_literal: true

require 'rails/railtie'
require 'industry_time'

module IndustryTime
  class Railtie < ::Rails::Railtie
    initializer 'industry_time.patch' do
      # Automatically apply the global monkey patches when Rails boots.
      IndustryTime.patch!
    end
  end
end
