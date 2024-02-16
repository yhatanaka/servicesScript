str = <<EOS
39°12'00.4"N 140°04'46.6"E
EOS

# require 'pp'
# str = gets
# puts str
# exit

# puts str
normStrAry1 = str.chomp.split(/ +/)
# normStrAry1 = str.chomp.split(/ +/).gsub(/ /, '').split(/[NE]/)
normStrAry2 = normStrAry1[0,2]
# resultAry = []
normStrAry2.each do |item|
	if item.match(/[^0-9\.°\'\"NE]/)
		puts 'oops!'
		exit
	elsif item.match(/^([0-9\.]+)°(?:([0-9\.]+)\')?(?:([0-9\.]+)\")?([NE])/)
		puts ($1.to_f + $2.to_f/60 + $3.to_f/3600).round(6)
	end
end
