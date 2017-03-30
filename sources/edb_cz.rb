require 'common'

class NalokCz < Common
  UA_PARAMS = { timeout: 10 }
  XPATHS = {
    urls_items: '//div[@id="pocet"]//a[@class="text"]/@href',
    base_doc: '//div[@id="twocolumns"]',
    page: {
      name: '//h1',
      street: './/span[@id="ctl00_cntPlaceHolderMain_BusinessProfileND1_lblStreet"]',
      zip: './/span[@id="ctl00_cntPlaceHolderMain_BusinessProfileND1_lblZip"]',
      city: './/span[@id="ctl00_cntPlaceHolderMain_BusinessProfileND1_lblCity"]',
      mobile: './/span[@id="ctl00_cntPlaceHolderMain_BusinessProfileND1_lblPhone"]',
      web: './/a[@id="ctl00_cntPlaceHolderMain_BusinessProfileND1_hplBizUrl"]/@href',
      commodity: '//h2[contains(text(),"O nás")]/following-sibling::p[1]'
    }
  }
  def initialize
    @folder = 'nalok_cz'
    super
  end

  def find_categories
    doc = Nokogiri::HTML(request('http://www.nalok.cz/farmy'))
    @params = doc.xpath('//form[@id="aspnetForm"]//input[@type="hidden"]').each_with_object({}) do |node, mem|
      value = node.at_xpath('./@value')
      name  = node.at_xpath('./@name')
      next if value.blank? || name.blank?
      mem[name.content] = value.content
    end
    %w(http://www.nalok.cz/farmy)
  end

  def find_urls(categories)
    doc = Nokogiri::HTML(request(categories[0]))
    doc.to_s.scan(%r{"/farmy/.+?"}).map do |url|
      "http://www.nalok.cz#{url.tr('"\\', '')}"
    end
  end
end
