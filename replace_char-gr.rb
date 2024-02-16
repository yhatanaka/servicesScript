#!/usr/bin/ruby
# -*- coding: utf-8 -*-
# usage: ruby replace_char-gr.rb input.txt
require 'pp'

search_txt = <<~EOS
①
②
③
④
⑤
⑥
⑦
⑧
⑨
⑩
⑪
⑫
⑬
⑭
⑮
⑯
⑰
⑱
⑲
⑳
㉑
㉒
㉓
㉔
㉕
㉖
㉗
㉘
㉙
㉚
EOS

replace_txt = <<~EOS
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
EOS

search_ary = search_txt.split("\n")
replace_ary = replace_txt.split("\n")
if search_ary.size != replace_ary.size
	echo 'size of search_txt and replace_txt are defferent.'
	exit
end #if

def search_reg(txt)
	return "#{txt}"
#	return txt
end #def

def replaced_pat(orig_txt,alt_txt)
	return "#{alt_txt}	"
#	return alt_txt
end #def

inputFile = ARGV.shift
input_txt = File.read(inputFile)
search_ary.each_with_index {|itm, idx|
	input_txt.gsub!(Regexp.new(search_reg(itm))) {|matched|
		replaced_pat(matched,replace_ary[idx])
	}
}

puts input_txt
