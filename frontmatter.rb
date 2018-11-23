#!/usr/bin/ruby
#  coding: utf-8

require 'date'
require 'pp'
Encoding.default_external = "UTF-8"
#Encoding.default_internal = "utf-8"

# Automator では言語設定が root なので外部コードが ASCII-8bit
# ARGV は代入しても froze されてるので，dup してからencode を utf-8 に
fm_text = ARGV.shift.dup.force_encoding("UTF-8")

def strip_all_spacies(str)
	return (str.strip).sub(/^[\p{blank}]+/, '').sub(/[\p{blank}]+$/, '')
#	return (str.strip).sub(/^[　]+/, '').sub(/[　]+$/, '')
end #def

fm_strings_ary = fm_text.split("\n").map do |string|
	strip_all_spacies(string)
end #map

# 元が空白のみで，空白削除したら何もない空文字の行は除く
fm_strings_ary = fm_strings_ary - ['']

def split_for_tags(str)
	result_ary = str.split(/[\p{blank}]*[,，][\p{blank}]*/)
end #def

def export_tags(ary)
	result = ''
	ary.each do |tag|
		puts '  - ' + tag
	end #each
end #def

puts '---'
puts 'templateKey: blog-post'
puts 'title: ' + fm_strings_ary[0]
puts 'date: ' + ((DateTime.now).new_offset()).strftime("%FT%T.%LZ")
puts 'description: ' + fm_strings_ary[1]
puts 'tags:'
export_tags(split_for_tags(fm_strings_ary[2]))
puts '---'



exit

pp fm_text.encoding
puts Encoding.default_internal
puts Encoding.default_external
puts __ENCODING__
#!/usr/bin/ruby -EUTF-8
