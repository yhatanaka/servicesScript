#!/usrbin/ruby -Ku
# -*- coding: utf-8 -*-

require 'pp'

# パスワード文字数
charCount = ARGV.shift.to_i

# 使用する文字タイプの配列
numAry = (0..9).to_a
smallCapAry = ('a'..'z').to_a
largeCapAry = ('A'..'Z').to_a

# 各タイプ配列のそのまたArrayから、各タイプ何文字あるかの配列を返す
def setArySizeAry(anAry)
	retnAry = []
	anAry.each do |i|
		retnAry.push(i.size)
	end #each
	return retnAry
end #def

# 実際に使用する文字タイプのセット
charArySet = [numAry, smallCapAry, largeCapAry]
# それぞれ何文字ずつあるか（）
charAryCountSet = setArySizeAry(charArySet)

# 各タイプの文字数の配列をもとに、配列全体を1として、特定の位置(0〜1)がどのタイプに当たるか返す
# [1.2.2]なら全体を1:2:2に分割、0.5は全体の真ん中だから2つめ(index 1)、0.9なら3つめ(最後, index 2)
def whereZone(i, zoneAry)
# どこに該当するか
	hitZone = 0
# 文字数の配列から、全体の文字数
	totalCharSize = 0
	zoneAry.each do |i|
		totalCharSize += i
	end #do
	rangeThreshold = 0
	zoneAry.each_with_index { |n, idx|
# どこまでがこのタイプなのか
		rangeThreshold += n
		if i*totalCharSize <= rangeThreshold
			hitZone = idx
			break
		end #if
	}
	return hitZone
end #def

# どのタイプから選ぶのか、文字数分の回数ランダムに選ぶ
pwTypeAry = (0...charCount).map{whereZone(Random.rand, charAryCountSet)}

# もし選ばれてないタイプがあったら…
absentNumAry = (0..charArySet.size-1).to_a - pwTypeAry.uniq
pp absentNumAry
# 最後の方を選ばれなかったタイプに置き換える
if absentNumAry.size >0
	pwTypeAry = pwTypeAry.shift(charCount - absentNumAry.size) + absentNumAry
end #do
pp pwTypeAry

pwChar = ''
pwTypeAry.each do |i|
	pwType = charArySet[i]
	pwChar += pwType[pwType.size * Random.rand].to_s
end #each

puts pwChar