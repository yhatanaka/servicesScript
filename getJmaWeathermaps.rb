require 'open-uri'
require "open_uri_redirections"
require 'pp'

pdfDir = '/Users/hatanaka/Desktop/作業中/進行中/天気/天気図PDF/'
urlList =<<~'EOS'
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fxfe5782_12.pdf	# 極東850hPa気温・風、700hPa上昇流／700hPa湿数、500hPa気温予想図 12,24h
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fxfe502_12.pdf	# 極東地上気圧・風・降水量／500hPa高度・渦度予想図 12,24h
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fupa502_12.pdf	# アジア太平洋500hPa高度・気温・風予想図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/feas504_12.pdf	# アジア地上気圧、850hPa気温／500hPa高度・渦度予想図 24h
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fxjp854_12.pdf	# 日本850hPa相当温位・風予想図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupa20_12.pdf	# アジア太平洋200hPa高度・気温・風・圏界面天気図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupa25_12.pdf	# アジア太平洋250hPa高度・気温・風天気図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupq35_12.pdf	# アジア500hPa・300hPa高度・気温・風・等風速線天気図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupq78_12.pdf	# アジア850hPa・700hPa高度・気温・風・湿数天気図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/axfe578_12.pdf	# 極東850hPa気温・風、700hPa上昇流／500hPa高度・渦度天気図
https://www.data.jma.go.jp/yoho/data/wxchart/quick/ASAS_COLOR.pdf	# 地上実況天気図カラー
https://www.data.jma.go.jp/yoho/data/jishin/kaisetsu_tanki_latest.pdf	# 短期予報解説資料
EOS

urlAry = urlList.split(/\n/)

urlAryMod = []
urlAry.each {|line|
# …ではじまってなければ（つまりコメントでなければ）
	unless line.match(/^\s*#.*/)
# #から後を削除して URL とする
		urlAryMod << line.sub(/\s*#.*/, '')
	end
}

urlAryMod.each_with_index {|url, idx|
	pdfFilename = File.basename(url)
	pdfFile = "#{pdfDir}#{pdfFilename}"
	URI.open(url, :allow_redirections => :all) do |file|
		open(pdfFile, "w+b") do |out|
			out.write(file.read)
		end
	end
	print "retreive #{pdfFilename}..."
	if idx + 1 < urlAryMod.count
		print " more #{urlAryMod.count - idx -1} files..."
		sleep 2
	end
	puts ''
	puts url
}


