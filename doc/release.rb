#!/usr/bin/env ruby

def make_changelog(new_major, new_minor, cur_major, cur_minor)
  log_format = "--pretty=format:'<li><pre><a href=\"http://github.com/isenseDev/rSENSE/commit/%H\">%h</a>%x09%an%x09%ad%x09%s</pre></li>'"
  log = `cd rSENSE && git log v#{cur_major}.#{cur_minor}...v#{new_major}.#{new_minor} #{log_format} --reverse | grep -v Merge`
  log = "<h1> rSENSE Changelog: v#{cur_major}.#{cur_minor}...v#{new_major}.#{new_minor} </h1>" + log
  logname = "changelogs/v#{cur_major}.#{cur_minor}---v#{new_major}.#{new_minor}.html"
  File.open(logname, 'w') { |file| file.write(log) }
end

ver_info = /.*v(\d+)\.(\d+).*/.match `cd rSENSE && git describe --tags`

cur_major = ver_info[1].to_i
cur_minor = ver_info[2].to_i

new_major = cur_major
new_minor = cur_minor

case ARGV[0]
when 'major'
  new_major = cur_major + 1
  new_minor = 0
when 'minor'
  new_minor = cur_minor + 1
else
  puts "Invalid mode, should be 'major' or 'minor."
  exit
end

dry = ARGV.include? '-n'

puts "New version will be v#{new_major}.#{new_minor}..."

# puts "Pulling (git pull origin master)...."
# if not dry
#  puts `cd rSENSE && git pull origin master`
# end

puts "Tagging (git tag v#{new_major}.#{new_minor})..."
unless dry
  puts `cd rSENSE && git tag v#{new_major}.#{new_minor}`
end

puts 'Generating Changelog(s)...'
unless dry
  make_changelog(new_major, new_minor, cur_major, cur_minor)
  if ARGV[0] == 'major'
    make_changelog(new_major, new_minor, cur_major, 0)
  end
end

puts 'Pushing tags back up to github...'

puts `cd rSENSE && git push tags --tags`

puts 'All Done!'

