#!ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'fileutils'
require 'pp'
require 'Oga'

inputFile = ARGV.shift
sendFlag = ARGV.shift

if inputFile.nil?
    puts 'Usage: this_script.rb hoge.html'
    puts '       rename hoge.html to hoge_orig.html, and make new hoge.html'
    exit
end #if

handle = File.open(inputFile)
document = Oga.parse_html(handle)

head = document.at_xpath('html/head')
link1 = head
#送付用
if sendFlag.nil?
    head.css('link').first['href'] = '../Qgis2threejs/Qgis2threejs.css'
    startRegexp = Regexp.new('./')
    head.css('script').each do |scriptTag|
    	scriptTag['src'].sub!(startRegexp,'../Qgis2threejs/')
    end #each
end
appendStyle = <<~EOS

#comment, #commentLarge {
  position: absolute;
  top: 0px;
  right: 0px;
  margin: 1px 2px;
  padding: 2px;
  background-color: white;
  box-shadow: 1px 2px 6px rgba(0,0,0,0.2);
  z-index: 100;
  display: visible;
  font-size: x-small;

}

#title {
  display: visible;
  position: absolute;
  top: 0px;
  left: 40px;
  margin: 0px;
  padding: 4px;
  background-color: white;
  box-shadow: 1px 2px 6px rgba(0,0,0,0.2);
  display: visible;
  font-size: small;
  z-index: 10;

}

h1 {
  font-size: medium;

}

#myname {
  font-size: 70%;
}

#showbtn {
  position: absolute;
  top: 0px;
  right: 0px;
  font-size: xx-small;
}
EOS

newStyle = Oga::XML::Element.new(:name => 'style')
newStyle.inner_text = appendStyle
head.children << newStyle


qr_coords_table = document.css('table#qr_coords_table caption')
qr_coords_table[0].children[0].text = 'クリックした場所の経緯度'

qr_layername_table = document.css('table#qr_layername_table caption')
qr_layername_table[0].children[0].text = 'レイヤー'

orbitbtn = document.css('div#orbitbtn')
orbitbtn[0].inner_text = 'クリック地点を中心に回転'

measurebtn = document.css('div#measurebtn')
measurebtn[0].inner_text = '距離計測'

pageinfo_h1s = document.css('div#pageinfo h1')
pageinfo_h1s.each do |pageinfo_h1|
    if pageinfo_h1.inner_text == 'Current View URL'
        pageinfo_h1.inner_text = '今現在表示しているビューの URL'
    elsif pageinfo_h1.inner_text == 'Usage'
        pageinfo_h1.inner_text = '操作方法'
    end #if
end #each

document.css('div#about img')[0]['src'].sub!('./','../Qgis2threejs/')

usageInJapaneseTxt = <<~EOS
マウス
左ボタン + 移動,		対象を中心に視点移動
マウスホイール,			ズームイン/アウト
右ボタン + 移動,		視線を上下左右にパン

キーボード
矢印キー,				視点を水平移動(前後左右)
シフト + 矢印キー,		対象を中心に視点移動
Ctrl + 矢印キー,		視線を上下左右にパン
シフト + Ctrl + ↑ / ↓,	ズームイン/アウト
L,						ラベル表示/非表示
R,						回転アニメーション開始/停止
W,						ワイヤーフレーム表示
シフト + R,				視点位置リセット
シフト + S,				画像保存
EOS

usageInJapanese = []
usageInJapaneseTxt.split("\n").each do |aRow|
    if aRow.size > 0
    usageInJapanese << aRow.split(/,\t*/)
    end #if
end #each

usageTable = document.css('table#usage tr')
usageTable.each_with_index do |tr,idx|
    tr.css('td').each_with_index do |td,i|
        td.inner_text = usageInJapanese[idx][i]
    end #for
end #each


# 拡張子
extname = File.extname(inputFile)
basename = File.basename(inputFile,extname)
targetFileDir = File.dirname(inputFile)
newFilename = targetFileDir + '/' + basename + '_new' + extname

# File.rename(targetDir + '/' + filename, targetDir + '/' + newFilename)


appendComment = <<~EOS

<!-- コピーライト表記 -->
<div id="comment">
<input id="showbtn" type="button" value="詳細" onclick="clickBtn2()" />
使用データ：<br/>
　国土地理院<br/>
　　<a href="https://fgd.gsi.go.jp/download/ref_dem.html" target="_blank">数値標高モデル</a>,<br/>
　　<a href="https://maps.gsi.go.jp/#14/39.099360/140.048862/&base=std&ls=std%7Cvlcd_chokai&blend=1&disp=11&lcd=vlcd_chokai&vs=c1g1j0h0k0l0u0t0z0r0s0m0f1&d=m" target="_blank">火山地形分類データファイル</a><br/>
　　　<a href="https://maps.gsi.go.jp/#14/39.099360/140.048862/&base=std&ls=std%7Cvlcd_chokai&blend=1&disp=11&lcd=vlcd_chokai&vs=c1g1j0h0k0l0u0t0z0r0s0m0f1&d=m" target="_blank">「鳥海山」</a><br/>
(高さ強調：×2倍)
</div>

<div id="commentLarge">
<input id="showbtn" type="button" value="×" onclick="clickBtn2()" />
地形データ：　　<a href="https://fgd.gsi.go.jp/download/ref_dem.html" target="_blank">国土地理院 数値標高モデル</a><br/>
地形分類データ：<a href="https://maps.gsi.go.jp/#14/39.099360/140.048862/&base=std&ls=std%7Cvlcd_chokai&blend=1&disp=11&lcd=vlcd_chokai&vs=c1g1j0h0k0l0u0t0z0r0s0m0f1&d=m" target="_blank">国土地理院 火山地形分類データファイル「鳥海山」D1-No.1015</a><br/>
地図画像：　　　<a href="https://maps.gsi.go.jp/development/ichiran.html" target="_blank">国土地理院 地理院タイル</a><br/>
<!--　測量法に基づく国土地理院長承認(複製)R 2JHf 12<br/>
　本製品を複製する場合には、国土地理院の長の承認を得なければならない。<br/>-->
<br/>
素材画像生成：　<a href="http://www.jizoh.jp/pages/gj0.html" target="_blank">ジオ地蔵.app (片栁由明 氏)</a><br/>
加工・合成：　　<a href="https://chokaitobishima.com" target="_blank">鳥海山・飛島ジオパーク</a> <span id="myname">畠中</span><br/>
<br/>
(高さ強調：×2倍)
</div>
<script>
//初期表示は非表示
document.getElementById("commentLarge").style.visibility ="hidden";

function clickBtn2(){
	const p2 = document.getElementById("commentLarge");

	if(p2.style.visibility=="visible"){
		// hiddenで非表示
		p2.style.visibility ="hidden";
	}else{
		// visibleで表示
		p2.style.visibility ="visible";
	}
}
</script>

</body>
EOS

# 拡張子
extname = File.extname(inputFile)
basename = File.basename(inputFile,extname)
fileDir = File.dirname(inputFile)
newFilename = basename + '_orig' + extname

newFile = fileDir + '/' + newFilename
File.rename(inputFile, newFile)
File.open(inputFile, 'w') do |fileOpen|
	fileOpen.write(document.to_xml.sub!('</body>',appendComment))
end

