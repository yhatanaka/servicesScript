#!//usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'

require 'nkf'
require 'pp'
require 'csv'
require 'nokogiri'

ARGV.each do |f|
	if File.extname(f) == '.html'
		inputFile = f
		outputFile = File.dirname(f) + '/' + File.basename(f, '.html') + '.csv'
		
		scrapeItemHash = {'c3_ext' => 'タイトル', 'c5' => '年月日', 'c17' => '時間'}
		
		begin
		    rowHtmlContent = File.read(inputFile)
		#    convertedHtmlContent = NKF.nkf('--ic=Shift_JIS --oc=UTF-8', rowHtmlContent)
		    htmlObject = Nokogiri::HTML.parse(rowHtmlContent, nil, 'Shift_JIS')
		    itemNo = nil
		    outputCSVArray = Array.new
		    outputCSVArray.push(scrapeItemHash.values)
		    htmlObject.xpath('//body/script').inner_text.split(';').each do |line|
		    # cなんちゃら[いくつ]="かんちゃら"
		        if /^(c\w+)\[([0-9]+)\]=\"(.+)\"/.match(line) && scrapeItemHash.has_key?($1) then
		            itemIndex = $1
		            itemString = $3
		            if $2 != itemNo then
		                outputCSVArray.push(Array.new)
		                itemNo = $2
		            end #if
		            case itemIndex
		            when 'c3_ext'
		                itemString = itemString.gsub(/\s+[0-9]{2}\/[0-9]{2}/,'').gsub(/\[[字再解双二デ]\]/,'').gsub(/\s+:追従/,'').gsub(/[　 ]/,'_').gsub('[SS]','').tr('０-９ａ-ｚＡ-Ｚ（）”“＃▽','0-9a-zA-Z()""#_')
		            when 'c5'
		                itemString = itemString.gsub('/','-')
		           end #case 
		            outputCSVArray[-1].push(itemString)
		        end #if
		    end #each
		# 例外は小さい単位で捕捉する
		rescue SystemCallError => e
		  puts %Q(class=[#{e.class}] message=[#{e.message}])
		rescue IOError => e
		  puts %Q(class=[#{e.class}] message=[#{e.message}])
		end
		
		if outputFile then
		    CSV.open(outputFile,"wb") do |outputCSV|
		    	outputCSVArray.each do |eachRow|
		    		outputCSV << eachRow
		    	end #each
		    end #
		elsif
		    puts 'you can set outputFile as ARGV, '
		end #if
	end #if
end