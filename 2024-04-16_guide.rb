#!ruby
# -*- coding: utf-8 -*-
#$KCODE='UTF8'
Encoding.default_external = "UTF-8"

data = <<~EOS
伊藤みふゆ,3月14日,釜磯他,5000,500
大江進,1月22日,釜磯他,5000,500
畠中裕之,2月27日,釜磯他,5000,500
畠中裕之,3月14日,釜磯他,5000,500
齋藤美由紀,2月27日,釜磯他,5000,500
齋藤美由紀,3月14日,釜磯他,5000,500
髙橋治,1月22日,釜磯他,5000,500
EOS

dataAry = data.split("\n").map {|row| row.split(',')}
dataHash = dataAry.each_with_object(Hash.new { |v, k| v[k] = []}) {|ary, hash|
	hash[ary[0]] << ary.drop(1)
}
dataHash.each {|name, toursAry|

mailSentences_1 = <<~EOS
#{name}さま

畠中です。

先日のガイド料精算では、12月末までの分のお支払いでしたが、
昨日会計より連絡あり、3月末分まで追加で精算しますとのことでした。

EOS

totalFee = 0
resultPay = 0

toursAry.each {|aTour|
date = aTour[0]
location = aTour[1]
aFee = aTour[2]
payWay = '現金払い'
totalFee += aFee.to_i
resultPay += aTour[3].to_i
mailSentences_2 = <<~EOS
#{date} #{location} #{aFee}円 #{payWay}
EOS

mailSentences_1 << mailSentences_2
}

if toursAry.size > 1
mailSentences_3 = <<~EOS
合計ガイド料 #{totalFee}円

EOS
mailSentences_1 << mailSentences_3
end #if

mailSentences_4 = <<~EOS
手数料納付額 #{resultPay}円

上記納付額、総会においでになる場合は総会の際、会計にお支払いくださいとのことでした。
総会欠席の場合は、とりあえず私の方で立て替えておきますので
後日精算ということでいかがでしょうか。


EOS

mailSentences_1 << mailSentences_4
print mailSentences_1
}
