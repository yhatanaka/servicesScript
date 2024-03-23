#!//usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'

# usage: ruby csv2kml.rb input.csv format.kml output.kml
require 'nkf'
require 'csv'
require 'rexml/document'
require 'yaml'
require 'pp'
include REXML

inputFile = ARGV.shift
formatFile = ARGV.shift
outputFile = ARGV.shift


dataTable = CSV.read(inputFile)
#outputColumnNumberArray = ['1','7','8']
outputArray = []

dataTable.each_with_index do |line, idx|
	outputArray.push([line[1],[line[8],line[7],'0']])
end #each_with_index
outputArray.shift
#p outputArray

doc = REXML::Document.new(open(formatFile))

outputArray.each do |aGeosite|
	placemark = REXML::Element.new('Placemark')

	sitename = REXML::Element.new('name')
	sitename.add_text(aGeosite[0])
	placemark.add_element(sitename)

	point = REXML::Element.new('Point')
	coordinates = REXML::Element.new('coordinates')
	coordinates.add_text(aGeosite[1].join(','))
	point.add_element(coordinates)
	placemark.add_element(point)

	styleUrl = REXML::Element.new('styleUrl')
	styleUrl.add_text('#icon-1899-FFEA00-nodesc')
#	styleUrl.add_text('#icon-503-DB4436-nodesc')
#	styleUrl.add_text('#icon-503-DB4436-nodesc')
#p styleUrl.text
	placemark.add_element(styleUrl)
p placemark.elements['styleUrl'].text
	doc.root.elements['Document'].add_element(placemark)
end #each

File.open(outputFile, 'w') do |file|
	doc.write(file, indent=4)
end #open


=begin
#pp doc.root
XPath.each(doc, '//Placemark'){|xmlelement|
#p YAML::dump( xmlelement.elements)
p(xmlelement.elements['name'].text)
p(xmlelement.elements['Point/coordinates'].text)
}
#p YAML::dump(item)
#p YAML::dump( xmlelement.elements)
=end