# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'rexml/document'
require 'pp'

outputAry = []
handle = File.open(ARGV.shift)
doc = REXML::Document.new(handle)

REXML::XPath.match(doc, '//outline').each do |outline|
	if outline.attribute('_note')
	note = outline.attribute('_note').value
	outputAry << note
	end
end

# \ で終わってたら改行せず次の行を続ける
puts outputAry.join("\n").gsub(/\\\n/, '')

=begin 
puts outputTxt.gsub(/\\\n/, '')


parser = Oga::XML::PullParser.new(handle)
parser.parse do |node|
  if node.is_a?(Oga::XML::PullParser)
  puts node.get('text')
#      puts node.get('_note') unless node.get('_note').strip.empty?    
   end    
end
=end