# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'pp'

handle = File.open(ARGV.shift, "rt:Shift_JIS:UTF-8").read.split("\n")

handle.each do |line|
	if /<a href=[^>]+>([^>]+)</.match(line)
		puts $1
	end #if
end #each
=begin 

require 'rexml/document'
# require 'Oga'

handle = File.open(ARGV.shift, "rt:Shift_JIS:UTF-8")
doc = REXML::Document.new(handle)

REXML::XPath.match(doc, '//td/a').each do |outline|
# 	if outline.attribute('_note')
# 	note = outline.attribute('_note').value
	puts outline
# 	end
end
=end


=begin 

parser = Oga::XML::PullParser.new(handle)
parser.parse do |node|
  if node.is_a?(Oga::XML::PullParser)
  puts node.get('text')
#      puts node.get('_note') unless node.get('_note').strip.empty?    
   end    
end
=end