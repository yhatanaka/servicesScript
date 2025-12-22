#!ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'csv'
require 'pp'
require 'rexml/document'

# KMLのaabbggrrカラーコードをGeoJSON/HTMLの#rrggbb形式に変換する
# KML: aa bb gg rr (透明度、青、緑、赤)
# HTML: # rr gg bb
def kml_color_to_html(kml_color)
  # aa(透明度)を無視し、bgrを抽出
  b = kml_color[2..3]
  g = kml_color[4..5]
  r = kml_color[6..7]
  
  "##{r}#{g}#{b}" # #rrggbb の形式で返す
rescue StandardError
  '#000000' # 失敗した場合は黒を返す
end

# REXML::Elementから特定のタグの値を取得
def get_tag_text(element, tag_name, namespace = nil)
  element.elements.each(tag_name) do |elem|
    # 名前空間が指定されている場合、要素のnamespaceが一致するかを確認
    if namespace.nil? || elem.namespace == namespace
      return elem.text
    end
  end
  nil
end

# ジオメトリを抽出
def extract_geometry(placemark)
  # geometry = nil
  # type = nil
  # coordinates = nil

  # Point
  if coords_tag = placemark.elements['Point/coordinates']
    coords = coords_tag.text.strip.split(',').map(&:to_f)
    # GeoJSONは[経度, 緯度]、KMLは[経度, 緯度, 高度]（高度は省略可）
    return [coords[0], coords[1]]

  # # LineString
  # elsif coords_tag = placemark.elements['LineString/coordinates']
  #   # KMLの座標文字列（空白区切りで経度,緯度,高度）を [経度, 緯度] の配列の配列に変換
  #   coordinates = coords_tag.text.strip.split(/\s+/).map do |coord|
  #     c = coord.split(',').map(&:to_f)
  #     [c[0], c[1]]
  #   end
  #   type = 'LineString'
# 
  # # Polygon
  # elsif boundary = placemark.elements['Polygon/outerBoundaryIs/LinearRing/coordinates']
  #   # KMLの座標文字列を [経度, 緯度] の配列の配列に変換
  #   coords_array = boundary.text.strip.split(/\s+/).map do |coord|
  #     c = coord.split(',').map(&:to_f)
  #     [c[0], c[1]]
  #   end
  #   # GeoJSON Polygonは [[リング座標1], [リング座標2], ...] の形式
  #   coordinates = [coords_array]
  #   type = 'Polygon'
  end

  # # ジオメトリが存在する場合にハッシュとして返す
  # if type && coordinates
  #   {
  #     'type' => type,
  #     'coordinates' => coordinates
  #   }
  # else
  #   nil
  # end
end

# KMLから色情報を抽出
def extract_color(placemark, styles)
  style_url = get_tag_text(placemark, 'styleUrl')
  style_id = get_tag_text(placemark, 'Style/@id')

  color_tag = nil
  
  # 1. Placemarkに直接Style要素がある場合
  if style_element = placemark.elements['Style']
    color_tag = get_tag_text(style_element, 'PolyStyle/color') || 
                get_tag_text(style_element, 'LineStyle/color') ||
                get_tag_text(style_element, 'IconStyle/color')
  end

  # 2. styleUrlで参照されるStyleMapまたはStyleがある場合
  if color_tag.nil? && style_url
    target_id = style_url.sub('#', '')
    if style_map = styles[target_id]
      # StyleMapの場合、通常は "normal" スタイルの参照を使用
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

    if style_element = styles[target_id]
      color_tag = get_tag_text(style_element, 'PolyStyle/color') || 
                  get_tag_text(style_element, 'LineStyle/color') ||
                  get_tag_text(style_element, 'IconStyle/color')
    end
  end

  if color_tag
    return kml_color_to_html(color_tag)
  else
    nil # 色情報が見つからない
  end
end

# descroption から、電気伝導度を抽出
def extractConduct(dscr)
    if dscr.sub(/\.+/, '.').match(/([0-9\.]+) *µs/) # 「..」に対処
        return $1
    end
end

# --- メイン処理 ---
KML_FILE = ARGV.shift.freeze
GEOJSON_FILE = 'output_for_umap.geojson'.freeze
KML_NAMESPACE = 'http://www.opengis.net/kml/2.2'.freeze

unless File.exist?(KML_FILE)
  puts "エラー: KMLファイルが見つかりません: #{KML_FILE}"
  exit
end

kml_doc = REXML::Document.new(File.new(KML_FILE))
rowAry = []
styles = {}

puts "KMLファイル #{KML_FILE} を読み込み中..."

# 1. すべてのStyleとStyleMapを先に抽出（IDをキーとするハッシュに格納）
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
# lon, lat
  aRow = geometry
  # KMLのnameとdescriptionを取得
  name = get_tag_text(placemark, 'name')
  aRow << name if name
  description = get_tag_text(placemark, 'description')
  puts "- #{name}"
  if description
    aRow << extractConduct(description)
    aRow << description
    puts extractConduct(description)
  else
    aRow << nil
    aRow << nil
    puts '*******************'
  end
  # aRow << description if description
  # 色情報を抽出
  color = extract_color(placemark, styles)

  if color
    # umapに色を指定するための特別なプロパティ
    # 値はJSON文字列にする必要がある
    aRow << color
    # puts " -> Placemark: #{name || '名称なし'}, 色: #{color}"
  else
    # puts " -> Placemark: #{name || '名称なし'}, 色: デフォルト (#000000)"
  end
  
  rowAry << aRow
end

headersAry = ['lon','lat','name','conduct','description','color']
headerRow = CSV::Row.new(headersAry, [], header_row: true)
aTable = CSV::Table.new([headerRow])
aTable.push(*rowAry)
print aTable.to_csv


# puts "\n✅ 処理が完了しました。"
# puts "出力ファイル: #{GEOJSON_FILE}"
# puts "Feature数: #{features.size}"


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