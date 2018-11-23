#!/usr/bin/ruby
ARGV.each do |f|
	puts f.gsub(/(.+)\t([0-9\-]+)\t.+/,'\1_\2' )
end