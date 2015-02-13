require 'simplecov'
SimpleCov.profiles.define 'rsense' do
  load_profile 'rails'
  SimpleCov.minimum_coverage 90
end
