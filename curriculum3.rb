#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

# Wikibooks のTOCをOmniOutliner で読み込める(OPMLで書き出してMindNode で使える) Tabインデントのテキストファイルに

require 'nkf'
require 'pp'
require 'nokogiri'

result = "\n"
ARGV.each do |f|
#inputFile = ARGV.shift
	
#	f = File.read(inputFile)
	
	def print_node(node)
		temp_result = ''
# textノード出力
		if node.text? then
# 空文字でなければ
			unless node.to_s.strip.empty? then
				node_text = node.to_s
# 1.3 などインデックスなら
				if /[0-9\.]+/ =~ node_text then
# 何階層目か
					indent_num = node_text.split('.').count
# 階層の分行頭にタブ
					while indent_num > 0
						temp_result << "\t"
						indent_num = indent_num - 1
					end #while
					temp_result << node_text
# インデックスの後にスペース，(その後に次の項目名続く)
					temp_result << ": "
				else
# インデックスでなく項目名なら，出力して改行
					temp_result << node_text
					temp_result << "\n"
				end #if
			end #unless
		else
		#    puts node.name
		end #if
		return temp_result
	end #def
	
	doc = Nokogiri::HTML.parse(f, nil, 'UTF-8')
	body = doc.at_css('body')
	body.traverse{|node|
		result << print_node(node)
	}
end
print result
