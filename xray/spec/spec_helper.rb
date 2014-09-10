ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.color_enabled = true
  config.include FactoryGirl::Syntax::Methods
  config.before { Mongoid.purge! }

  config.include JSONHelpers
end
