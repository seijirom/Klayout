while l=gets
  if l=~/^geomSpace\((\S+), *(\S+), *(\S+), *(\".*\")\)/
    layer1 = $1.downcase
    layer2 = $2.downcase
    separation = $3+'.um'
    msg = $4
    puts '# ' + l.chomp + " =>\n"
    puts "r_#{layer1}_#{layer2}_s = #{layer1}.separation(#{layer2}, #{separation}); r_#{layer1}_#{layer2}_s.output(#{msg})"
  elsif l=~/^geomSpace\((\S+), *(\S+), *(\".*\")\)/
    layer = $1.downcase    
    space = $2+ '.um'
    msg = $3
    puts '# ' + l.chomp + " =>\n"
    puts "r_#{layer}_s = #{layer}.space(#{space}); r_#{layer}_s.output(#{msg})"
  elsif l=~/^#/
    puts '# ' + l
  else
    puts l
  end
end
