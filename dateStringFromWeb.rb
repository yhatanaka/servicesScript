require 'open-uri'
require 'nokogiri'
require "open_uri_redirections"
require 'pp'

#pp ARGV[0].match(%r(https?://([^/]+)))[1]

def scrp_ismedia(htmlObj)
# body > div.blockMain > div.blockContainer.display-flex-wrap > div.blockContainer_left2 > div.articleHeader > div.elementSectionHeadingsWithSuffix > img:nth-child(1)
 	outputDate =''
 	htmlObj.at_css('body > div.blockMain > div.blockContainer.display-flex-wrap > div.blockContainer_left2 > div.articleHeader > div.elementSectionHeadingsWithSuffix').css('img').each do |aImage|
	  	if imageDateString = aImage.attribute('src').text.match(/.+([0-9_]+)\.png/)
	  		outputDate += imageDateString[1]
	  	end #if
	end #eack
	return outputDate.gsub('_','-')
end #def

def makeHashFromString(str)
	seperatedAry = str.split("\n")
	resultHash = Hash.new
	seperatedAry.each do |row|
		hashKeyValueAry = row.split("\t")
		if hashKeyValueAry.size == 2
			resultHash[hashKeyValueAry[0]] = hashKeyValueAry[1]
		end #if
	end #each
	return resultHash
end #def

def scrp(htmlObj, domainSelecter, isTest)
	domainDateDom =<<'EOS'
biz-journal.jp	#entryDateBox > span.entryDate
bizzine.jp	#container > main > div.main > article > p:nth-child(7) > span
blogs.yahoo.co.jp	#atcllst > div > div:nth-child(2) > ul > li.date > a > span
business.nikkeibp.co.jp	#topIcons > p
codezine.jp	#article_body_block > div.authorDetail.cf > div.day
courrier.jp	#container > section.article_detail_area > article > div.article_meta > div > span
cyblog.jp	body > div.l-container > div.l-contents > div > div > main > article > header > div > ul > li.c-meta__item.c-meta__item--published
digital.asahi.com	#MainInner > div.ArticleTitle > div.Title > p.LastUpdated
gihyo.jp	#article > div:nth-child(1) > div.sectionProperty > p.date
ikoma.cocolog-nifty.com	#beta-inner > h2
internet.watch.impress.co.jp	#main > article > div > div.article-info > p.publish-date
japan.cnet.com	#leaf-column > div.leaf-headline-block > div.leaf-headline-inner > span.date > a
japan.zdnet.com	#contents-left > p
japanese.engadget.com	div.t-meta-small\@s.t-meta\@m\+ > div
karapaia.com	#main > div.widget.widget-entry > div.widget-header > div > span
labaq.com	#blog > div.fullbody > div.blogbodytop > div.date
lite-ra.com	#entryDate
markezine.jp	#contents > div:nth-child(8) > div.detailBlock > div.authorDetail.cf > div.day
medical.nikkeibp.co.jp	body > div.body > div.main > div.wrapper > div.contents > div.article > div.article-header > div.wrapper > p.date
monoist.atmarkit.co.jp	#update
natgeo.nikkeibp.co.jp	#newsArticle > div.article > div > div.articleTitleBox > div.toolBox > div
news.mynavi.jp	body > div.wrapper > div.container > div.body > main > div.article-header > p.article-header__update
news.yahoo.co.jp	#content-body > section > div > div.hd > div.articleInfo > span
tech.nikkeibp.co.jp	#article > div.articleTitleBox > div.infoWrap > div.date
techfactory.itmedia.co.jp	#update
toyokeizai.net	#signage > div.author-date.clearfix.defaultarticle > div.date
webronza.asahi.com	#contents > div.entryInfo > p.date
www.asahi.com	#MainInner > div.ArticleTitle > div.Title > p.LastUpdated
www.atmarkit.co.jp	#update
www.foocom.net	#date
www.huffingtonpost.jp	div.timestamp > span.timestamp__date.timestamp__date--published
www.itmedia.co.jp	#update
www.kankyo-business.jp	#mainCont > div.article > div.inner > div.clearfix.mb20 > div > div.sns_box_lt > span
www.lifehacker.jp	body > main > div:nth-child(2) > div.lh-primary > div.lh-entryDetail > div > div.lh-entryDetail-header > div > div > p > time
www.mag2.com	#metadate
www.mylohas.net	body > main > div.l-Block.-postRegular > div.l-Block_PrimaryWrap > div > div.po-Post > div.po-Post_Post > div > div.po-Post_PostContainerLeft > p.po-Post_PostDate > time
www.newsweekjapan.jp	#content > div.contentPanel.noShadowThis_noShadowBottom.clickableArea.containTitleTxt_RR > div.panelNoShadow.entryDetail.clearfix > div.clearfix > div.entryDetailHeadline.border_btm.clearfix > div > div.entryDetailData > div.date
www.nikkei.com	#CONTENTS_MAIN > div.cmn-section.cmn-indent > dl.cmn-article_status.cmn-clearfix > dd
www.nippon.com	#main > dl.detail_maintit > dd.data_lang.cb > span
www.technologyreview.jp	#outline > p > span
yamagata-np.jp	#time
EOS
	domainSelecterHash = makeHashFromString(domainDateDom)
 	if domainSelecterHash[domainSelecter] !=nil
 		if isTest
			return htmlObj.at_css(domainSelecterHash[domainSelecter])
		else
			return htmlObj.at_css(domainSelecterHash[domainSelecter]).text.gsub(/\s\s+/, '')
		end #if 
	else
		return ''
	end #if
end #def


# 最後に「test」つけると debug モード
# testFlag = false
# if ARGV.shift == 'test'
# 	testFlag = true
# end #if



dateString =''
url = ARGV.shift
# allow https => http redirect
doc = Nokogiri::HTML(open(url, :allow_redirections => :all))
siteDomain = url.match(%r(https?://([^/]+)))[1]
case siteDomain
 	when 'gendai.ismedia.jp' then
 		dateString = scrp_ismedia(doc)
	else
		dateString = scrp(doc, siteDomain, testFlag)
end #case

if testFlag
	pp dateString
else
	print dateString + "\n\n"
end
