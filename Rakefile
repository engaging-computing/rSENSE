#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rsense::Application.load_tasks

namespace :ckeditor do
  desc 'Create nondigest versions of some ckeditor assets (e.g. moono skin png)'
  task :create_nondigest_assets do
    fingerprint = /\-[0-9a-f]{32}\./
    for file in Dir['public/assets/ckeditor/contents-*.css', 'public/assets/ckeditor/skins/moono/*.png', 'public/assets/vis/*.png']
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
