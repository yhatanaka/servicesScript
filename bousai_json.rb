#!ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'csv'
require 'json'

class Bousai
	def makeBousai(inputCsv)
		inputCsv.by_row!
		inputCsv.delete_if {|row|
			row['種類'] == ' '
		}
	end #def
	
	def makePoint(pointHash, featureType)
		returnHash = {'type' => 'Feature'}
		propertiesHash = {}
		coordinates = []
		pointHash.each do |key,value|
			if key == 'gsi'
				coordinates = /https\:\/\/.+\/\#[0-9]+\/([0-9\.]+)\/([0-9\.]+)\/.+/.match(value).to_a.values_at(2,1).map!{|i| i.to_f}
# https://maps.gsi.go.jp/#18/39.059125/139.888964/&base=std&ls=std&disp=1&vs=c1g1j0h0k0l0u0t0z0r0s0m0f1
			elsif value.nil?
				propertiesHash[key] = ""
			else
				propertiesHash[key] = value
			end #if
		end #each
		coordinatesHash = {'type'=>'Point'}
		coordinatesHash['coordinates'] = coordinates
# 		if featureType == 'info'
# 			returnHash['properties'] = modPropertiesInfo(propertiesHash)
# 		elsif featureType == 'warn'
# 			returnHash['properties'] = modPropertiesWarn(propertiesHash)
# 		end #if
		returnHash['geometry'] = coordinatesHash
		return returnHash
	end #dif

	def modPropertiesInfo(propHash)
		iconHash = {'医療機関'=>'medicine', '警察署・交番'=>'keisatu', '消防署'=>'shoubo', 'AED'=>'aed', '防火水槽'=>'bouka', '老人ホーム'=>'roujinhome', '避難所'=>'hinan', '避難ビル'=>'hinan-bldg'}
		propHash['info_type'] = 'info'
puts '1: ' + propHash['種類']
# 		propHash['id'] = iconHash[propHash['種類']]
# 		propHash['icon'] = iconHash[propHash['種類']] + '-marker.png'
		propHash.delete('種類')
		propHash
	end #def
	
	def modPropertiesWarn(propHash)
		iconHash = {'火災'=>'0', '浸水'=>'1', '土砂崩れ'=>'2', '道路閉塞(家屋倒壊)'=>'4', '道路閉塞(ブロック塀倒壊)'=>'5', '津波'=>'7', '道路閉塞(液状化)'=>'8 '}
		propHash['info_type'] = 'warn'
		propHash['id'] = 'warn' + iconHash[propHash['種類']]
		propHash['icon'] = 'icon-warn' + iconHash[propHash['種類']] + '.png'
		propHash['risk_type'] = iconHash[propHash['種類']]
		propHash.delete('種類')
		propHash.delete('場所')
		propHash
	end #def


	def printCsv(features)
		rootJson = {}
		rootJson['type'] = 'FeatureCollection'
		rootJsonFeatures = []
		features.each do |featureType,points|
			points.each do |point|
				pp makePoint(point,featureType)
# 			rootJsonFeatures << makePoint(points,featureType)
			end #each
		end #each
		rootJson['features'] = rootJsonFeatures
		rootJson
	end #def
	
end #class

begin
	aBousaiList = Bousai.new
	aBousaiFileList = {}
	options = {headers: true}
	Dir::chdir(ARGV.shift)
	Dir::glob('*') do |sourceCsv|
		thisCsv = CSV::read(sourceCsv, **options)
		fileBasename = File::basename(sourceCsv, '.csv')
		if /.+info/.match(fileBasename)
			aBousaiFileList['info'] = thisCsv
		elsif /.+warn/.match(fileBasename)
# 			aBousaiFileList['warn'] = thisCsv
		end #if
# 		print JSON.dump(aBousaiList.printCsv(aBousaiFileList))
	end #glob
		pp aBousaiList.printCsv(aBousaiFileList)
# 例外は小さい単位で捕捉する
rescue SystemCallError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
rescue IOError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
end



exit

f = ''
File.open(inputFile, 'rt:UTF-8', invalid: :replace, undef: :replace, replace: '?') do |file|
  f = file.read
end

aHash = JSON.parse(f,max_nesting: 5)
# aHash = JSON.parse(f, symbolize_names: true)


=begin 
{"type"=>"FeatureCollection",
 "features"=>
  [{"type"=>"Feature",
    "properties"=>
     {"icon"=>"medicine-marker.png",
      "id"=>"medicine_01",
      "name"=>"菅原医院",
      "description"=>"",
      "info_type"=>"info"},
    "geometry"=>
     {"type"=>"Point",
      "coordinates"=>[139.8889696598053, 39.059316559107906]}}]}


{"type"=>"FeatureCollection",
 "features"=>
  [{"type"=>"Feature",
    "properties"=>
     {"icon"=>"medicine-marker.png",
      "id"=>"medicine_01",
      "name"=>"菅原医院",
      "description"=>"",
      "info_type"=>"info"},
    "geometry"=>
     {"type"=>"Point",
      "coordinates"=>[139.8889696598053, 39.059316559107906]}},
   {"type"=>"Feature",
    "properties"=>
     {"icon"=>"keisatu-marker.png",
      "id"=>"keisatu_01",
      "name"=>"酒田警察署吹浦駐在所",
      "description"=>"",
      "info_type"=>"info"},
    "geometry"=>
     {"type"=>"Point",
      "coordinates"=>[139.88234996795651, 39.07067479631139]}},
   {"type"=>"Feature",
    "properties"=>
     {"icon"=>"aed-marker.png",
      "id"=>"AED_01",
      "name"=>"AED",
      "description"=>"吹浦防災センター内",
      "info_type"=>"info"},
    "geometry"=>
     {"type"=>"Point",
      "coordinates"=>[139.87974286079407, 39.07383578472888]}},
   {"type"=>"Feature",
    "properties"=>
     {"icon"=>"hinan-marker.png",
      "id"=>"hinan_01",
      "name"=>"吹浦防災センター",
      "description"=>"",
      "info_type"=>"info"},
    "geometry"=>
     {"type"=>"Point", "coordinates"=>[139.8797482252121, 39.07383578472888]}},
   {"type"=>"Feature",
    "properties"=>
     {"icon"=>"roujinhome-marker.png",
      "id"=>"roujinhome_01",
      "name"=>"特別養護老人ホームにしだて",
      "description"=>"",
      "info_type"=>"info"},
    "geometry"=>
     {"type"=>"Point",
      "coordinates"=>[139.87455010414124, 39.07633448960066]}},
   {"type"=>"Feature",
    "properties"=>
     {"icon"=>"hinan-marker.png",
      "id"=>"hinan_02",
      "name"=>"吹浦小学校",
      "description"=>"",
      "info_type"=>"info"},
    "geometry"=>
     {"type"=>"Point",
      "coordinates"=>[139.87280666828156, 39.07342765452719]}},
   {"type"=>"Feature",
    "properties"=>
     {"icon"=>"icon_warn7.png",
      "id"=>"tsunami_01",
      "name"=>"【通行禁止】津波",
      "description"=>"",
      "info_type"=>"warn",
      "range"=>200,
      "start"=>"2022/11/12 0:00",
      "stop"=>"2022/11/13 23:00",
      "message1"=>"【通行禁止】津波による浸水エリアに近づいています!通行はできません!",
      "message2"=>"【通行禁止】津波による浸水エリアに侵入しました!危険です!ただちにエリアから離れてください!",
      "risk_type"=>7},
    "geometry"=>
     {"type"=>"Point", "coordinates"=>[139.877028465271, 39.089701023743906]}},
   {"type"=>"Feature",
    "properties"=>
     {"icon"=>"icon_warn7.png",
      "id"=>"tsunami_02",
      "name"=>"【通行禁止】津波",
      "description"=>"",
      "info_type"=>"warn",
      "range"=>150,
      "start"=>"2022/11/12 0:00",
      "stop"=>"2022/11/13 23:00",
      "message1"=>"【通行禁止】津波による浸水エリアに近づいています!通行はできません!",
      "message2"=>"【通行禁止】津波による浸水エリアに侵入しました!危険です!ただちにエリアから離れてください!",
      "risk_type"=>7},
    "geometry"=>
     {"type"=>"Point", "coordinates"=>[139.8786163330078, 39.09484710170876]}},
   {"type"=>"Feature",
    "properties"=>
     {"icon"=>"icon_warn7.png",
      "id"=>"tsunami_03",
      "name"=>"【通行禁止】津波",
      "description"=>"",
      "info_type"=>"warn",
      "range"=>150,
      "start"=>"2022/11/12 0:00",
      "stop"=>"2022/11/13 23:00",
      "message1"=>"【通行禁止】津波による浸水エリアに近づいています!通行はできません!",
      "message2"=>"【通行禁止】津波による浸水エリアに侵入しました!危険です!ただちにエリアから離れてください!",
      "risk_type"=>7},
    "geometry"=>
     {"type"=>"Point",
      "coordinates"=>[139.87702310085297, 39.07189089820402]}},
   {"type"=>"Feature",
    "properties"=>
     {"icon"=>"icon_warn2.png",
      "id"=>"dosha_01",
      "name"=>"【通行禁止】土砂崩れが発生",
      "description"=>"",
      "info_type"=>"warn",
      "range"=>100,
      "start"=>"2022/11/12 0:00",
      "stop"=>"2022/11/13 23:00",
      "message1"=>"【通行禁止】土砂崩れが発生しているエリアに近づいています!通行はできません!",
      "message2"=>"【通行禁止】土砂崩れが発生しているエリアに侵入しました!危険です!ただちにエリアから離れてください!",
      "risk_type"=>2},
    "geometry"=>
     {"type"=>"Point",
      "coordinates"=>[139.87329483032227, 39.084975161830634]}}]}

=end