# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

require 'csv'
require 'pp'

# 距離(km) 40,65,100,130,155,190
dist = ARGV.shift

# P波、S波の時速(km/h)
vP = 40
vS = 65

# 定義域
xMax = 200
# 最大振幅
max_ampl = 1
# 減衰係数(大きいほど早く減衰)
attnt = 0.02
# 摂動の最大振幅
deltaAmpl = 0.5

# -1〜1の乱数
def randNum()
	return rand(0) * 2 - 1
end #def

# 最大振幅 ampl の変動
def deltaRate(ampl)
	(randNum() + randNum()) * ampl/2
end #def
#puts deltaRate(deltaAmpl)
#exit

table = CSV::Table.new([], headers: [:time, :value])

# 最大値 a, 減衰係数 b
def ampl(x, a, b)
	value = a * Math.exp(-1 * b * x)
	return value
end #def

for num in 1..xMax do

#振幅
# + と - 交互に、変動も
	y = -1.pow(num) * ampl(num, max_ampl, attnt) * (1 + deltaRate(deltaAmpl))
	rowValues = [num, y]
	table << CSV::Row.new(table.headers, rowValues)
end

puts table.to_csv