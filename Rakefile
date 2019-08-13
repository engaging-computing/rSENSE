#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

# Temporary fix for last_comment deprecation
# Probably has to do with rspec or rake version

module LastCommentFix
  def last_comment
    last_description
  end
end
Rake::Application.send :include, LastCommentFix

Rsense::Application.load_tasks

namespace :ckeditor do
  desc 'Create nondigest versions of some ckeditor assets (e.g. moono skin png)'
  task :create_nondigest_assets do
    fingerprint = /\-[0-9a-f]{32}\./
    Dir['public/assets/ckeditor/contents-*.css', 'public/assets/ckeditor/skins/moono/*.png', 'public/assets/vis/*.png'].each do |file|
      next unless file =~ fingerprint
      nondigest = file.sub fingerprint, '.'
      FileUtils.cp file, nondigest, verbose: true
    end
  end
end

# auto run ckeditor:create_nondigest_assets after assets:precompile
Rake::Task['assets:precompile'].enhance do
  Rake::Task['ckeditor:create_nondigest_assets'].invoke
end

namespace :db do
  task :preprep do
    if ENV['DB']
      puts "Switching db config to #{ENV['DB']}"
      system("cp config/database.#{ENV['DB']}.yml config/database.yml")
    else
      puts 'No DB variable set'
    end
  end
end

namespace :test do
  task :pg do
    system('DB=postgres rake db:preprep')
    system('rake test')
    system('DB=default rake db:preprep')
  end
end

task :dump do
  system('rake db:data:dump')
  system('mv db/data.yml public/media')
  system('tar czvf /tmp/dump.tar.gz public/media')
  system('mv /tmp/dump.tar.gz public')
end

task :load do
  system("mkdir /tmp/#{$PROCESS_ID}")
  system("mv public/media /tmp/#{$PROCESS_ID}")
  system('tar xzvf public/dump.tar.gz')
  system('mv public/media/data.yml db')
  system('rake db:data:load')
end

if %w(development test).include? Rails.env
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new do |task|
    task.formatters = ['fuubar']
  end

  task(:coffeelint).clear
  task :coffeelint do
    conf = Rails.root.join('.coffeelint')
    success = true
    ['app', 'lib'].each do |dd|
      success &&= Coffeelint.run_test_suite(dd, config_file: conf.to_s)
    end
    fail 'Goats! (you probably failed coffeelint)' unless success
  end

  task(:default).clear
  task :default do
    Rake::Task['coffeelint'].invoke
    Rake::Task['rubocop'].invoke
    Rake::Task['test'].invoke
  end
end
