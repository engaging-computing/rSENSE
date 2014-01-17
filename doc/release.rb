#!/usr/bin/env ruby

def makeChangelog(newMajor, newMinor, curMajor, curMinor)
  logFormat = "--pretty=format:'<li><pre><a href=\"http://github.com/isenseDev/rSENSE/commit/%H\">%h</a>%x09%an%x09%ad%x09%s</pre></li>'"
  log = `cd rSENSE && git log v#{curMajor}.#{curMinor}...v#{newMajor}.#{newMinor} #{logFormat} --reverse | grep -v Merge`
  log = "<h1> rSENSE Changelog: v#{curMajor}.#{curMinor}...v#{newMajor}.#{newMinor} </h1>" + log
  logname = "changelogs/v#{curMajor}.#{curMinor}---v#{newMajor}.#{newMinor}.html"
  File.open(logname, 'w') { |file| file.write(log) }
end

verInfo = /.*v(\d+)\.(\d+).*/.match `cd rSENSE && git describe --tags`

curMajor = verInfo[1].to_i
curMinor = verInfo[2].to_i

newMajor = curMajor
newMinor = curMinor


case ARGV[0]
  when "major"
    newMajor = curMajor + 1
    newMinor = 0
  when "minor"
    newMinor = curMinor + 1
  else
    puts "Invalid mode, should be 'major' or 'minor."
    exit
end

dry = ARGV.include? "-n"

puts "New version will be v#{newMajor}.#{newMinor}..."

#puts "Pulling (git pull origin master)..."
#if not dry
#  puts `cd rSENSE && git pull origin master`
#end

puts "Tagging (git tag v#{newMajor}.#{newMinor})..."
if not dry
  puts `cd rSENSE && git tag v#{newMajor}.#{newMinor}`
end

puts "Generating Changelog(s)..."
if not dry
  makeChangelog(newMajor, newMinor, curMajor, curMinor)
  if ARGV[0] == "major"
    makeChangelog(newMajor, newMinor, curMajor, 0)
  end
end

puts "Pushing tags back up to github..."

puts `cd rSENSE && git push tags --tags`

puts "All Done!"

