#!ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

# require 'csv'
require 'pp'
require 'rexml/document'
require 'json'

# REXML::Elementから特定のタグの値を取得
def get_tag_text(element, tag_path)
  # REXMLのXPath風の指定を使用して要素を検索
  element.elements.each(tag_path) do |elem|
    # 要素名だけでなく、適切なパス全体が一致するかを確認
    return elem.text
  end
  nil
end

# GeoJSON Featureのジオメトリを抽出
def extract_geometry(placemark)
  geometry = nil
  type = nil
  coordinates = nil

  # Point
  if coords_tag = placemark.elements['Point/coordinates']
    coords = coords_tag.text.strip.split(',').map(&:to_f)
    # GeoJSONは[経度, 緯度]、KMLは[経度, 緯度, 高度]（高度は省略可）
    coordinates = [coords[0], coords[1]]
    type = 'Point'

  # LineString
  elsif coords_tag = placemark.elements['LineString/coordinates']
    # KMLの座標文字列（空白区切りで経度,緯度,高度）を [経度, 緯度] の配列の配列に変換
    coordinates = coords_tag.text.strip.split(/\s+/).map do |coord|
      c = coord.split(',').map(&:to_f)
      [c[0], c[1]]
    end
    type = 'LineString'

  # Polygon
  elsif boundary = placemark.elements['Polygon/outerBoundaryIs/LinearRing/coordinates']
    # KMLの座標文字列を [経度, 緯度] の配列の配列に変換
    coords_array = boundary.text.strip.split(/\s+/).map do |coord|
      c = coord.split(',').map(&:to_f)
      [c[0], c[1]]
    end
    # GeoJSON Polygonは [[リング座標1], [リング座標2], ...] の形式
    coordinates = [coords_array]
    type = 'Polygon'
  end

  # ジオメトリが存在する場合にハッシュとして返す
  if type && coordinates
    {
      'type' => type,
      'coordinates' => coordinates
    }
  else
    nil
  end
end

# KMLからアイコンのhref (URL) を抽出
def extract_icon_url(placemark, styles)
  # 1. Placemarkに直接Style要素がある場合
  if style_element = placemark.elements['Style']
    if href = get_tag_text(style_element, 'IconStyle/Icon/href')
      return href
    end
  end

  # 2. styleUrlで参照されるStyleMapまたはStyleがある場合
  if style_url = get_tag_text(placemark, 'styleUrl')
    target_id = style_url.sub('#', '')
    
    # StyleMapの場合、通常は "normal" スタイルの参照を使用
    if style_map = styles[target_id]
      style_map.elements.each('Pair') do |pair|
        if get_tag_text(pair, 'key') == 'normal'
          normal_style_url = get_tag_text(pair, 'styleUrl')
          if normal_style_url
            target_id = normal_style_url.sub('#', '')
            break
          end
        end
      end
    end

    # Styleからhrefを取得
    if style_element = styles[target_id]
      if href = get_tag_text(style_element, 'IconStyle/Icon/href')
        return href
      end
    end
  end

  nil # アイコンURLが見つからない
end

# --- メイン処理 ---
KML_FILE = ARGV.shift.freeze
GEOJSON_FILE = 'output4gsi_icon.geojson'.freeze
KML_NAMESPACE = 'http://www.opengis.net/kml/2.2'.freeze

unless File.exist?(KML_FILE)
  puts "エラー: KMLファイルが見つかりません: #{KML_FILE}"
  exit
end

kml_doc = REXML::Document.new(File.new(KML_FILE))
features = []
styles = {}

puts "KMLファイル #{KML_FILE} を読み込み中..."

# 1. すべてのStyleとStyleMapを先に抽出（IDをキーとするハッシュに格納）
# <kml><Document>直下にあるStyleおよびStyleMapを抽出対象とする
kml_doc.elements.each('kml/Document/*') do |element|
  next unless element.is_a?(REXML::Element)
  
  style_id = element.attributes['id']
  if (element.name == 'Style' || element.name == 'StyleMap') && style_id
    styles[style_id] = element
  end
end
puts "抽出されたStyle/StyleMapの数: #{styles.size}"

# 2. Placemarkを走査し、GeoJSON Featureに変換
kml_doc.elements.each('kml/Document//Placemark') do |placemark|
  geometry = extract_geometry(placemark)
  next unless geometry # ジオメトリがないPlacemarkはスキップ

  # KMLのnameとdescriptionを取得
  name = get_tag_text(placemark, 'name')
  description = get_tag_text(placemark, 'description')
  
  # アイコンURLを抽出 (Pointフィーチャの場合に有効)
  icon_url = extract_icon_url(placemark, styles)
  
  # GeoJSONのプロパティを作成
  properties = {}
  properties['name'] = name if name
  properties['description'] = description if description
  properties['_markerType'] = 'Icon'

  
  # アイコンURLをプロパティとして追加
  properties['_icon_url'] = icon_url if icon_url
  
  puts " -> Placemark: #{name || '名称なし'}, アイコンURL: #{icon_url || 'なし'}"

  # GeoJSON Featureの構成
  feature = {
    'type' => 'Feature',
    'geometry' => geometry,
    'properties' => properties
  }
  features << feature
end

# GeoJSON FeatureCollectionの構成
geojson = {
  'type' => 'FeatureCollection',
  'features' => features
}

# GeoJSONをファイルに書き出し
File.open(GEOJSON_FILE, 'w') do |f|
  # 見やすいように整形して書き出す
  f.write(JSON.pretty_generate(geojson))
end

puts "\n✅ 処理が完了しました。"
puts "出力ファイル: #{GEOJSON_FILE}"
puts "Feature数: #{features.size}"

exit
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