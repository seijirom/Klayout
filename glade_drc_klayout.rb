# coding: utf-8
klayout_drc_version ='klayout v0.2: 2019/6/25'
count = nil
overlap = nil
while l=gets
  if count && count > 0
    count = count -1
    puts l
    next
  elsif l=~/^# simpe function to print # errors - unused\./
    count = 4
    puts l + '=begin'
    next
  elsif l=~/^# Initialise DRC package\./
    count = 3
    puts l + '=begin'
    next
  elsif l=~/^# Get raw layers/ 
    count = 25
    puts l + <<EOL
nwl = input(1, 0)
nwl_dp = input(2, 0)
diff = input(3, 0) 
pol = input(5, 0)
hpol = input(6,0)
cnt = input(7, 0)
ml1 = input(8, 0)
via1 = input(9, 0) 
ml2 = input(10, 0)
via2 = input(11, 0)
ml3 = input(12, 0)
text = input(13, 0)
frame = input(14, 0)
res = input(15, 0)
cap = input(16, 0)
dio = input(17, 0)
parea = input(18, 0)
narea = input(19, 0)
pad = input(20, 0)
dm_dcn = input(101, 0)
dm_pcn = input(102, 0)
dm_nscn = input(103, 0)
dm_pscn = input(104, 0)
dm_via1 = input(105, 0)
dm_via2 = input(106, 0)
EOL
    puts '=begin'
    next
  elsif l=~/^# Form connectivity/
    count = 9
    puts l + '=begin'
    next
  elsif l=~/^# Exit DRC package, freeing memory/
    count = 1
    puts l + '=begin'
    next
  elsif l=~/\S+ = geomGetRawShapes\("(\S+)", "drawing"\)/
    overlap = $1.downcase
    count = 1
    puts '=begin'
  elsif count
    puts l + '=end'
    count = nil
    if overlap
      if l =~ /geomArea\(.*, 0, 0, *(\".*\")\)/
        puts "#{overlap}_ovlp = #{overlap}.raw.merged(2); #{overlap}_ovlp.output(#{$1})"
        overlap = nil
      end
    end
    next
  end
  
  if l=~/^# ver1.31/ #!!!!! please change this part for newer Glade DRC file
    puts '#' + l + "# #{klayout_drc_version}: seijiro.moriyama@anagix.com"
    puts 'report("Output database")'
  elsif l=~/^print "(.*)"/
    puts "puts '#{$1}'"
  elsif l=~/^#/ || l=~/^PSUB = geomNot\(NWL\)/
    puts '#' + l
  elsif l=~/^geomSpace\((\S+), *(\S+), *(\S+), *(\".*\")\)/
    layer1 = $1.downcase
    layer2 = $2.downcase
    separation = $3+'.um'
    msg = $4
    puts '# ' + l.chomp + " =>\n"
    #    puts "r_#{layer1}_#{layer2}_s = #{layer1}.separation(#{layer2}, #{separation}); r_#{layer1}_#{layer2}_s.output(#{msg})"
    puts "r_#{layer1}_#{layer2}_s = #{layer1}.separation(#{layer2}.not_interacting(#{layer1}), #{separation}); r_#{layer1}_#{layer2}_s.output(#{msg})"    
  elsif l=~/^geomSpace\((\S+), *(\S+), *(\".*\")\)/
    layer = $1.downcase    
    space = $2+ '.um'
    msg = $3
    puts '# ' + l.chomp + " =>\n"
    puts "r_#{layer}_s = #{layer}.space(#{space}); r_#{layer}_s.output(#{msg})"
  elsif l=~/(\S+) *= *geomAnd\((\S+), geomNot\((\S+)\)\)/
    puts '# ' + l.chomp + " =>\n"
    puts "#{$1.downcase} = #{$2.downcase}.outside(#{$3.downcase})"
  elsif l=~/(\S+) *= *geomAnd\((\S+), *(\S+)\)/
    puts '# ' + l.chomp + " =>\n"
    puts "#{$1.downcase} = #{$2.downcase} & #{$3.downcase}"
  elsif l=~/(\S+) *= *geomOr\((\S+), *(\S+)\)/
    puts '# ' + l.chomp + " =>\n"
    puts "#{$1.downcase} = #{$2.downcase} | #{$3.downcase}"
  elsif l=~/geomWidth\((\S+), *(\S+), *(\".*\")\)/
    puts '# ' + l.chomp + " =>\n"   
    puts "#{$1.downcase}_w = #{$1.downcase}.width(#{$2}); #{$1.downcase}_w.output(#{$3})"
  elsif l=~/geomEnclose\((\S+), *(\S+), *(\S+), *(\".*\")\)/
    puts '# ' + l.chomp + " =>\n"   
    puts "#{$1.downcase}_e = #{$1.downcase}.enclosing(#{$2.downcase}, #{$3}); #{$1.downcase}_e.output(#{$4})"
  elsif l=~/geomExtension\((\S+), *(\S+), *(\S+), *(\".*\")\)/
    puts '# ' + l.chomp + " =>\n"   
    puts <<EOL
#{$1.downcase}_edges        = #{$1.downcase}.edges
#{$1.downcase}_gate_edges   = #{$1.downcase}_edges.interacting(#{$2.downcase})
other_#{$1.downcase}_edges  = #{$1.downcase}_edges.not_interacting(#{$2.downcase})
# ope_cd = “other #{$1.downcase} edges close to #{$2.downcase}”
ope_cd = other_#{$1.downcase}_edges.separation(#{$2.downcase}.edges, #{$3}, projection).first_edges
r_#{$1.downcase}_x2 = ope_cd.interacting(#{$1.downcase}_gate_edges); r_#{$1.downcase}_x2.output(#{$4})
EOL
  elsif l=~/(\S+) *= *geomAnd\((\S+), geomNot\((\S+)\)\)/
    puts '# ' + l.chomp + " =>\n"
    puts "#{$1.downcase} =  {$2.downcase}.outside({$3.downcase})"
  elsif l=~/geomArea\((\S+), *0, 0, *(\".*\")\)/
    puts '# ' + l.chomp + " =>\n"
    puts "#{$1.downcase}.output(#{$2})"
  elsif l=~/geomArea\(geomAnd\((\S+), *(\S+)\), 4, 4, *(\".*\")\)/ 
    puts '# ' + l.chomp + " =>\n"
    puts "#{$1.downcase}_ns = #{$1.downcase}.not_in(#{$2.downcase}); #{$1.downcase}_ns.output(#{$3})"
  else
    puts l
  end
  puts "Finished"
end
