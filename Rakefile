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

namespace :test do
  task :pg do
    system("DB=postgres rake db:preprep")
    system("rake test")
    system("DB=default rake db:preprep")
  end
end

task :dump do
  system("rake db:data:dump")
  system("mv db/data.yml public/media")
  system("tar czvf /tmp/dump.tar.gz public/media")
  system("mv /tmp/dump.tar.gz public")
end

task :load do
  system("mkdir /tmp/#{$$}")
  system("mv public/media /tmp/#{$$}")
  system("tar xzvf public/dump.tar.gz")
  system("mv public/media/data.yml db")
  system("rake db:data:load")
end
