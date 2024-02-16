require 'open-uri'
require 'nokogiri'
require "open_uri_redirections"
require 'pp'
require 'nkf'

domainDateDom =<<~'EOS'
	biz-journal.jp	#entryDateBox > span.entryDate
	bizzine.jp	#container > main > div.main > article > p:nth-child(7) > span
	blogs.yahoo.co.jp	#atcllst > div > div:nth-child(2) > ul > li.date > a > span
	business.nikkeibp.co.jp	#topIcons > p
	codezine.jp	#article_body_block > div.authorDetail.cf > div.day
	courrier.jp	#container > section.article_detail_area > article > div.article_meta > div > span
	cyblog.jp	li.c-meta__item.c-meta__item--published
	d.hatena.ne.jp	#days > div > h2 > a > span.date
	digital.asahi.com	#MainInner > div.ArticleTitle > div.Title > p.LastUpdated
	gihyo.jp	#article > div:nth-child(1) > div.sectionProperty > p.date
	ikoma.cocolog-nifty.com	#beta-inner > h2
	internet.watch.impress.co.jp	#main > article > div > div.article-info > p.publish-date
	japan.cnet.com	div.leaf-headline-inner > span.date > a
	japan.zdnet.com	#contents-left > p.author
	japanese.engadget.com	div.t-meta-small\@s.t-meta\@m\+ > div
	jbpress.ismedia.jp	body > div > div.l-contents > main > article > header > div.l-row > div.article-header-info
	karapaia.com	#main > div.widget.widget-entry > div.widget-header > div > span
	labaq.com	#blog > div.fullbody > div.blogbodytop > div.date
	lite-ra.com	#entryDate
	mainichi.jp	span.articletag-date.is-articledetail
	markezine.jp	#contents > div:nth-child(8) > div.detailBlock > div.authorDetail.cf > div.day
	medical.nikkeibp.co.jp	body > div.body > div.main > div.wrapper > div.contents > div.article > div.article-header > div.wrapper > p.date
	monoist.atmarkit.co.jp	#update
	natgeo.nikkeibp.co.jp	#newsArticle > div.article > div > div.articleTitleBox > div.toolBox > div
	news.mynavi.jp	p.article-header__update
	news.yahoo.co.jp	#content-body > section > div > div.hd > div.articleInfo > span
	sci-tech.jugem.jp	#main > div:nth-child(2) > div.entry_date
	style.nikkei.com	#shareBoxTop > p
	tech.nikkeibp.co.jp	#article > div.articleTitleBox > div.infoWrap > div.date
	techfactory.itmedia.co.jp	#update
	techtarget.itmedia.co.jp	#cmsDate > #update
	tmaita77.blogspot.com	#Blog1 > div.blog-posts.hfeed > div:nth-child(1) > h2 > span
	toyokeizai.net	#signage > div.author-date.clearfix.defaultarticle > div.date
	webronza.asahi.com	#contents > div.entryInfo > p.date
	www.asahi.com	#MainInner > div.ArticleTitle > div.Title > p.LastUpdated
	www.atmarkit.co.jp	#update
	www.businessinsider.jp	article > div.p-post-byline > ul > li.p-post-bylineDate
	www.foocom.net	#date
	www.huffingtonpost.jp	div.timestamp > span.timestamp__date.timestamp__date--published
	www.ibm.com	div.dw-article-authordate > span.dw-article-pubdate
	www.itmedia.co.jp	#update
	www.kankyo-business.jp	div.sns_box_lt > span
	www.lifehacker.jp	#__next > div.block_lBlock__1OZ4- > div > div.article_pArticle_Head__LUOI5 > div.article_pArticle_MetaWrapper__1WTJS > p.article_pArticle_MetaDate__3zwRD
	www.mag2.com	#metadate
	www.mylohas.net	body > main > div.l-Block.-postRegular > div.l-Block_PrimaryWrap > div > div.po-Post > div.po-Post_Post > div > div.po-Post_PostContainerLeft > p.po-Post_PostDate > time
	www.newsweekjapan.jp	div.entryDetailHeadline.border_btm.clearfix > div > div.entryDetailData > div.date
	www.nikkei.com	#CONTENTS_MAIN > div.cmn-section.cmn-indent > dl.cmn-article_status.cmn-clearfix > dd
	www.nippon.com	#main > dl.detail_maintit > dd.data_lang.cb > span
	www.technologyreview.jp	#outline > p > span
	www.tokyo-np.co.jp	#Contents > div.News-detail > div.News-headarea > div > p
	yamagata-np.jp	#time
	nazology.net	div.post-head > div > div.post-head__detail > div.post-head__date
EOS

def scrp_ismedia(htmlObj)
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

def scrp(htmlObj, domainSelecter, aDomainDateDom)
	domainSelecterHash = makeHashFromString(aDomainDateDom)
	dateCssPath = domainSelecterHash[domainSelecter]
	if dateCssPath !=nil
		return htmlObj.at_css(dateCssPath).text
	else
		return ''
	end #if
end #def


dateString =''

# 最後に「test」つけると debug モード
testFlag = true
if ARGV.is_a?(Array) && ARGV.size == 2
	testFlag = false
end #if

if testFlag
	# allow https => http redirect
	url = ARGV.shift
	doc = Nokogiri::HTML(open(url, :allow_redirections => :all))
else
	url = ARGV[0]
	utf8_html = NKF.nkf("--utf8",ARGV[1])
	doc = Nokogiri::HTML.parse(utf8_html)
end
siteDomain = url.match(%r(https?://([^/]+)))[1]

case siteDomain
 	when 'gendai.ismedia.jp' then
 		dateString = scrp_ismedia(doc)
	else
		dateString = scrp(doc, siteDomain, domainDateDom)
end #case

if testFlag
	pp dateString
else
	print dateString.gsub(/\s\s+/, '') + "\n\n"
end
