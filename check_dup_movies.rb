#!/usr/bin/ruby

require 'pp'

m3T_f = '/Volumes/Marshal3T/TV'
h4T_f = '/Volumes/HGST4T/backup/TV'
m3T_t = 'm3T.txt'
h4T_t = 'h4T.txt'

#m3T = Dir.open(m3T_f, &:to_a)
#h4T = Dir.open(h4T_f, &:to_a)
#
#File.open(m3T_t, 'w') do |output|
#	m3T.sort.each do |value|
#		output.puts(value)
#	end #each
#end #open
#
#File.open(h4T_t, 'w') do |output|
#	h4T.sort.each do |value|
#		output.puts(value)
#	end #each
#end #open

m3T_new = []
IO.foreach(m3T_t) do |input|
	m3T_new << input.chomp
end #open

h4T_new = []
IO.foreach(h4T_t) do |input|
	h4T_new << input.chomp
end #open


will_move = []

h4T_new.each do |value|
	if !(m3T_new.include?(value))
		will_move << value
	end #if
end #each

pp will_move
exit


#