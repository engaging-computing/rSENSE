#!/usr/bin/env ruby

target_ver = ARGV[0]

puts 'Pulling latest state and switching to requested version...'
puts `cd rSENSE && git pull origin --tags`
puts `cd rSENSE && git pull origin master`
puts `cd rSENSE && git checkout #{target_ver}`

puts 'Preparing environment...'
puts `cd rSENSE && bundle install`
puts `cd rSENSE && rake db:migrate RAILS_ENV=production`
puts `cd rSENSE && bundle exec rake assets:precompile RAILS_ENV=production`

puts 'Restarting apache...'
puts `sudo service apache2 reload`

puts 'Done.'
