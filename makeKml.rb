#!//usr/bin/ruby

# usage: ruby makeKml.rb output.kml
# require 'nkf'
# require 'csv'
require 'rexml/document'
# require 'yaml'
require 'pp'
require 'stringio'
include REXML

# inputFile = ARGV.shift
# formatFile = ARGV.shift
outputFile = ARGV.shift

input_txt = <<EOS
ヨーロッパカブトエビ,5月26日28日、6月9日
# 	38.723490,140.011066,立谷沢の志田さんの水田
# 	38.952704,139.92263,八幡の佐藤良平さんの水田
# 
# フサカ,4月2日
# 	39.091,139.896,
# 
# スナガニ
# 	39.059829,139.869335,西浜海水浴場の南方砂浜
# 	39.040172,139.862069,遊佐町十里塚海水浴場
# 	39.059829,139.869335,海水浴場北側の砂浜
# 
# ウミセミ
# 	39.993581,139.843561,白木の日光川河口の北方
# 
# ゲンジホタル
# 	38.873716,140.021149,平田の楯山川の上（長田の奥へ）
# 	38.922652,140.016900,相沢川上流（丸山村）
# 	38.916919,140.015287,ホタルの里（道屋敷の相沢川対岸）
# 
# ザリガニ
# 	38.757389,139.763715,大山下池の「ほとりあ」湿地田
# イモリ
# 	38.584,140.020,月山の弥陀ヶ原
# ヤモリ,8月20日
# 	38.926286,139.857833,旧市内の住宅地（北新橋2丁目にも生息している）
# 
# ハッチョウトンボ,7月8日
# 	39.048770,139.955917,遊佐町藤井の藤井公園
# 
# マダラナニワトンボ,2020年10月21日で遅かった。2021年10月7日には産卵中のものを沢山確認。
# 	38.655402,139.986760,月山高原牧場の東　叶宮橋を渡って十字路の東側沼地
# 
# モリアオガエル
# 	38.896327,139.943043,平田あいあいの下の池（玉の池）
# イバラトミヨ
# 	39.072350,139.887658,
# 
# 連れて行きたい施設や場所
# 	平田水辺の楽校,水生昆虫・淡水魚・湿地の植物
# 		38.896245,139.998504,
# 	
# 	松山のヒョウタン池,カブトムシのトラップなど
# 		38.857424,139.979309,
# 	
# 	鳥海イヌワシみらい館
# 		39.032654,140.029938,
# 	
# 	鶴岡市自然学習交流館（大山の「ほとりあ」）
# 		38.758540,139.763016,
# 	
# 	三崎山の経緯度観測点
# 		39.120005,139.891713,寺田寅彦が設置
# 	
# 	砂金採取地点
# 		38.636665,140.010603,
# 	
# 	科沢の化石観察採取地点
# 		38.688129,140.003724,
EOS


format_kml = <<EOS
<?xml version='1.0' encoding='UTF-8'?> 
<kml xmlns='http://www.opengis.net/kml/2.2'>
	<Document>
		<name></name>
	</Document>
</kml>
EOS

# doc = REXML::Document.new(format_kml)

# def string2Xml(ary)
# 	
# end #def

def string2nest(element,ary)
# 	aLine = ary.shift
# 	if aLine
end #def

root = {}
string2nest(root, input_txt)

prevIndentLevel = 0
inputLinesAry = input_txt.split(/\R/).delete_if {|item|
	/\#/.match(item)
}
pp inputLinesAry
exit


input_txt.each_line do |aLine|
	indentLevel = 0
# インデントレベル(タブ個数)カウント
	while /\t(.+)/.match(aLine)
		aLine = $1
		indentLevel += 1
	end
# 「北緯,東経,説明」?
	if /([0-9]{2}\.[0-9]+),([0-9]{3}\.[0-9]+),?(.+)/.match(aLine)
		puts '北緯: ' + $1 + ' , 東経: ' + $2 + ' , 説明: ' + $3
	end #if
	lineAry = aLine.chomp.split(',')
	title = lineAry.shift
	description = lineAry.shift
puts indentLevel
puts title
puts description
puts
end #each_line

rootElement = doc.root.elements['Document']

pretty_formatter = REXML::Formatters::Pretty.new
output = StringIO.new
pretty_formatter.write(rootElement, output)
puts output.string
exit


parentLevel = nil
folder = REXML::Element.new('Folder')

placemark = REXML::Element.new('Placemark')
sitename = REXML::Element.new('name')
sitename.add_text( )
placemark.add_element(sitename)

point = REXML::Element.new('Point')
coordinates = REXML::Element.new('coordinates')
coordinates.add_text( )
point.add_element(coordinates)

placemark.add_element(point)

doc.root.elements['Document'].add_element(placemark)


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