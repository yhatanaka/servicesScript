#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

# R の関数名をスネークケースからキャメルケースに

require "pp"

result = []
funcNameHash = {}
input = ARGV.shift
inputAry = input.split("\n")

# hoge <- function の hoge
funcNameRegex = /(\S+)\s+\<\-\s+function/

# 上の funcNameRegex の(\S+) つまり hoge の部分を返す
def  searchFuncName(str, searchRegex)
	return str[searchRegex, 1]
end #def

# 
def camelCaseName(str)
	return str.gsub(/_([a-z])/) {
		|string| $1.upcase
	}
end #def

# puts camelCaseName(input)

inputAry.each do |f|
	if (funcName = searchFuncName(f,funcNameRegex))
		camelCaseFuncName = camelCaseName(funcName)
		funcNameHash[funcName] = camelCaseFuncName
		outputLine = f.gsub(funcName, camelCaseFuncName)
	else
		outputLine = f
	end #if
	result.push(outputLine)
end

outputLineJoined = result.join("\n")
funcNameHash.each do |oldName, newName|
	outputLineJoined.gsub!(oldName, newName)
end #each

puts outputLineJoined + funcNameHash.to_s