# 多数の点をほぼほぼ均等に散布するための変位 n=0の場合少し補正 Fibonacci数列からヒント
include Math
def placeFibonacci(centerLatLonAry, n, dist)
# a=(1+5^(1/2))/2, a^(-2) (=1/(1+a))
	angleStep = 137.5
	distStep = dist
	distShift = 1.0 # 0の点をどれくらいずらすか
	power = 0.521 # 距離を計算する際のべき乗の指数
	angle = n*angleStep*PI/180
	if n == 0
		r = distShift*distStep
	else
		r = (n ** power)*distStep
	end
	x = r*cos(angle)
	y = r*sin(angle)
	return [centerLatLonAry[0]+y, centerLatLonAry[1]+x]
end
