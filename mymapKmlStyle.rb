#!/usrbin/ruby -Ku
# -*- coding: utf-8 -*-

# qgisで書き出したKMLファイルの<Placemark>に写真(<description>)を追加
# ruby addName2qgisKml.rb qgis.kml > newKml.kml

require 'rexml/document'
require 'rexml/xpath'
require 'pp'

inputFile = ARGV.shift
#inputFile = '/Users/hatanaka/Dropbox/qgis/2024-11-30_看板/2025-03-07.kml'

doc = REXML::Document.new(File.new(inputFile))


# styleUrl ごとに Placemark の配列をハッシュに
# {fk_type1:[place1_1, place1_2,...] fk_type2:[place2_1, place2_2,...] ...}
placemarkTypeHash = doc.get_elements('//Placemark').each_with_object(Hash.new { |v, k| v[k] = []}) {|aPlacemark, hash|
	hash[aPlacemark.elements['styleUrl'].text] << aPlacemark.elements['name'].text
}

pp placemarkTypeHash
exit

doc.elements.each('//Placemark') {|placemark|
# 	placemarkName = placemark.elements['ExtendedData/SchemaData']
}

print doc.to_s

=begin

<Data name="gx_media_links">
<value><![CDATA[http://chokai-tobishima.net/2025-03-04_yuza/IMG_6907.jpeg http://chokai-tobishima.net/2025-03-04_yuza/IMG_6907.jpeg]]></value>
</Data>

=end
