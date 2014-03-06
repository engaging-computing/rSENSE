#!/usr/bin/env ruby

coffee_file = ARGV[0]

unless coffee_file =~ /\.coffee/
  raise Exception.new("Expected a .coffee file")
end

File.open(coffee_file) do |ff|
  indent = 0
  spaces = 0

  stops = [0]

  ff.each_line do |line|
    line.chomp!
    line.sub!(/\s*$/, '')
    line.sub!(/;*$/, '')

    if line =~ /\t/
      raise Exception.new("Tabs can die in a fire")
    end

    if line =~ /^\s*$/
      puts
      next
    end

    if line =~ /^\s*#/
      puts line
      next
    end


    pre = line.match(/^\s*/)[0].size

    case
    when pre > spaces
      # indent
      indent += 1
      stops[indent] = pre
    when pre < spaces
      # outdent
      
      stops.each_index do |ii|
        if stops[ii] == pre
          indent = ii
          stops = stops[0..ii]
          break
        end
      end
    end

    #puts "#{spaces}, #{pre}, #{indent}, #{stops}"

    spaces = pre
    puts line.sub(/^\s*/, " " * (2 * indent))
  end
end
