#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rsense::Application.load_tasks

namespace :db do
  task :preprep do
    if ENV['DB']
      puts "Switching db config to #{ENV['DB']}"
      system("cp config/database.#{ENV['DB']}.yml config/database.yml")
    else
      puts "No DB variable set"
    end
  end
end
