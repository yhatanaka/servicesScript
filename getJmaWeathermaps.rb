require 'open-uri'
require "open_uri_redirections"
require 'pp'
require 'optparse'
# require 'date'

opt = OptionParser.new
params = {}
#  --GMT 12 or 00 〜_12.pdf or 〜_00.pdf
# +3hくらいでアップデート。つまり、日付変わったあたりで GMT 12 (JST GMT+0900 で21時)のもの、昼頃 GMT 00 (JST GMT+0900 で9時)のものが。
opt.on('--GMT VAL') {|v| v }
opt.parse!(ARGV, into: params)

# p ARGV
# p params
gmt = params[:GMT]

pdfDir = '/Users/hatanaka/Desktop/作業中/進行中/天気/天気図PDF'
stockedPdfDir = '/Users/hatanaka/Dropbox/気候・気象/天気図解析'
# 変数展開
urlList =<<~"EOS"
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fxfe5782_#{gmt}.pdf	# 極東850hPa気温・風、700hPa上昇流／700hPa湿数、500hPa気温予想図 12,24h
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fxfe502_#{gmt}.pdf	# 極東地上気圧・風・降水量／500hPa高度・渦度予想図 12,24h
# https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fupa502_#{gmt}.pdf	# アジア太平洋500hPa高度・気温・風予想図
# https://www.jma.go.jp/bosai/numericmap/data/nwpmap/feas504_#{gmt}.pdf	# アジア地上気圧、850hPa気温／500hPa高度・渦度予想図 24h
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fxjp854_#{gmt}.pdf	# 日本850hPa相当温位・風予想図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupa20_#{gmt}.pdf	# アジア太平洋200hPa高度・気温・風・圏界面天気図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupa25_#{gmt}.pdf	# アジア太平洋250hPa高度・気温・風天気図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupq35_#{gmt}.pdf	# アジア500hPa・300hPa高度・気温・風・等風速線天気図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupq78_#{gmt}.pdf	# アジア850hPa・700hPa高度・気温・風・湿数天気図
https://www.jma.go.jp/bosai/numericmap/data/nwpmap/axfe578_#{gmt}.pdf	# 極東850hPa気温・風、700hPa上昇流／500hPa高度・渦度天気図
https://www.data.jma.go.jp/yoho/data/wxchart/quick/ASAS_COLOR.pdf	# 地上実況天気図カラー
https://www.data.jma.go.jp/yoho/data/jishin/kaisetsu_tanki_latest.pdf	# 短期予報解説資料
EOS

# urlList =<<~'EOS'
# https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fxfe5782_12.pdf	# 極東850hPa気温・風、700hPa上昇流／700hPa湿数、500hPa気温予想図 12,24h
# https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fxfe502_12.pdf	# 極東地上気圧・風・降水量／500hPa高度・渦度予想図 12,24h
# # https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fupa502_12.pdf	# アジア太平洋500hPa高度・気温・風予想図
# # https://www.jma.go.jp/bosai/numericmap/data/nwpmap/feas504_12.pdf	# アジア地上気圧、850hPa気温／500hPa高度・渦度予想図 24h
# https://www.jma.go.jp/bosai/numericmap/data/nwpmap/fxjp854_12.pdf	# 日本850hPa相当温位・風予想図
# https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupa20_12.pdf	# アジア太平洋200hPa高度・気温・風・圏界面天気図
# https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupa25_12.pdf	# アジア太平洋250hPa高度・気温・風天気図
# https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupq35_12.pdf	# アジア500hPa・300hPa高度・気温・風・等風速線天気図
# https://www.jma.go.jp/bosai/numericmap/data/nwpmap/aupq78_12.pdf	# アジア850hPa・700hPa高度・気温・風・湿数天気図
# https://www.jma.go.jp/bosai/numericmap/data/nwpmap/axfe578_12.pdf	# 極東850hPa気温・風、700hPa上昇流／500hPa高度・渦度天気図
# https://www.data.jma.go.jp/yoho/data/wxchart/quick/ASAS_COLOR.pdf	# 地上実況天気図カラー
# https://www.data.jma.go.jp/yoho/data/jishin/kaisetsu_tanki_latest.pdf	# 短期予報解説資料
# EOS

urlAry = urlList.split(/\n/)

urlAryMod = []
urlAry.each {|line|
# …ではじまってなければ（つまりコメントでなければ）
	unless line.match(/^\s*#.*/)
# #から後を削除して URL とする
		urlAryMod << line.sub(/\s*#.*/, '')
	end
}

# stockedPdfDir に今日の日付のディレクトリ(Y-M-d)がなければ、作る
todaysDateStr = Date.today.to_s
todaysDir = "#{stockedPdfDir}/#{todaysDateStr}"
if !Dir.exist?(todaysDir)
	rslt = Dir.mkdir(todaysDir)
	if rslt != 0
		p 'auch! 今日の日付のフォルダ作れなかったよ〜'
	end
end

urlAryMod.each_with_index {|url, idx|
	pdfFilename = File.basename(url)
	pdfFile_1 = "#{pdfDir}/#{pdfFilename}"
# 	PDFファイルの、拡張子(.pdf)の前
	pdfBasename = File.basename(pdfFilename, '.pdf')
# ASAS_COLOR.pdf, kaisetsu_tanki_latest.pdf の2つは、日付のディレクトリに保存する際にファイル名の最後に _12, _00 つける
	if pdfBasename == 'ASAS_COLOR' || pdfBasename == 'kaisetsu_tanki_latest'
		pdfFilename = "#{pdfBasename}_#{gmt}.pdf"
	end
	pdfFile_2 = "#{todaysDir}/#{pdfFilename}"
	URI.open(url, :allow_redirections => :all) do |file|
		open(pdfFile_1, "w+b") do |out|
			out.write(file.read)
		end
# 日付ディレクトリにコピー
		FileUtils.cp(pdfFile_1, pdfFile_2)
	end
	print "retreive #{pdfFilename}..."
	if idx + 1 < urlAryMod.count
		print " more #{urlAryMod.count - idx -1} files..."
		sleep 2
	end
	puts ''
	puts url
}


