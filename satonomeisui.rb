# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

inputFile = '/Users/hatanaka/Downloads/里の名水・やまがた百選_2025-06-27.txt'

returnAry = []
handle = File.open(inputFile).read.split("\n")

handle.each do |line|
	if /^([0-9]+)(.+)（(.+)）/.match(line)
		returnAry << [$3,$2]
	end
end
meisuiHash = returnAry.each_with_object(Hash.new {|v, k| v[k] = []}) {|mizu, hash|
	hash[mizu[0]] << mizu[1]
}

meisuiHash.each {|k,v|
puts k + ', ' + v.size.to_s
}