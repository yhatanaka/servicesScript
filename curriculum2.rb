#!//usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'

require 'nkf'
require 'pp'
require 'nokogiri'

#inputFile = "/Users/hatanaka/Downloads/3年理科.html"
inputFile = ARGV.shift

f = File.read(inputFile)

def print_node(node)
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
	      	print "\t"
	      	indent_num = indent_num - 1
	      end #while
	      print node_text
# インデックスの後にスペース，(その後に次の項目名続く)
	      print ": "
      else
# インデックスでなく項目名なら，出力して改行
	      puts node_text
      end #unless
    end
  else
#    puts node.name
  end
end

doc = Nokogiri::HTML.parse(f)
body = doc.at_css('body')
puts
body.traverse{|node|
  print_node(node)
}