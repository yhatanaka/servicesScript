#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'pp'
#require 'Date'

toAddress = ''

mailTitle = '【遊佐エリア・ガイド料明細書のご確認依頼】'

mailBodyOrig = <<EOS
様
いつもたいへんお世話になっております。
昨年は当エリアのガイドをご担当いただきありがとうございました。
4月から12月までのガイド料明細書を送付しますので、内容のご確認をお願いいたします。
当エリア以外で担当されたガイド料は、担当エリア毎に明細書が送付されますので、予めご了承の程お願いいたします。
また、新会計システム導入の関係から、2024年1～3月のガイド料につきましては、来年度の精算とさせていただきます。
1～3月にご担当された方には、たいへん申し訳ございませんが、何卒ご理解を賜りますようお願いいたします。
ご不明な点などにつきましては、当方までご照会をいただければ幸いです。

尚、添付した明細書のご確認結果につきましては、3月5日（火）まで、このメールまたは電話でご連絡をお願いいたします。

遊佐エリアリーダー
畠中裕之
y.hatanaka@gmail.com
090-3469-0195
EOS

mailBody = mailBodyOrig.gsub(/(\r\n|\r|\n)/){"\n"}
openCommand = 'open mailto:' + toAddress + %Q[\?subject='] + mailTitle + %q['\&body='] + mailBody + %Q[\']
#p openCommand
exec openCommand
#?subject=''\&body=hello;"
#p mailTitle
#p mailBodyOrig
