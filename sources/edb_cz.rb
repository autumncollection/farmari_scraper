require 'common'

class EdbCz < Common
  UA_PARAMS = { timeout: 10 }
  XPATHS = {
    urls_items: '//a[@class="neklient"]/@href',
    urls_paging: '//div[@id="divStrankovacH"]/a[@class="sel"]' \
      '/following-sibling::a[1]/@href',
    base_doc: '//div[@id="main"]',
    page: {
      name: '//h1',
      street: './/div[@id="divInfo"]//span[@itemprop="streetAddress"]',
      city: './/div[@id="divInfo"]//span[@itemprop="addressLocality"]',
      zip: './/div[@id="divInfo"]//span[@itemprop="postalCode"]',
      ico: './/div[@id="divInfo"]//p[contains(.,"I")]',
      tel: './/div[@id="divInfo"]//p[@itemprop="telephone"]',
      info: './/div[@id="divInfo"]//p[contains(., "Okres")]',
      web: './/div[@id="divInfo"]/p/a[contains(@onclick,"neklient+WWW")]/@href',
      commodity: ['//p[@id="pUzText"]', '//div[@id="divSyntText"]'],
      categories: '//div[@id="pKlasifikace"]//strong'
    }
  }
  def initialize
    @folder = 'edb_cz'
    super
  end

  def parse_url(node)
    "#{node.content}"
  end

  def find_categories
    %w(http://www.edb.cz/katalog-firem/zemedelstvi-a-lesnictvi/pestovani-plodin/ovoce/?ext=2,4,6,11,16&stat=2
      http://www.edb.cz/katalog-firem/zemedelstvi-a-lesnictvi/pestovani-plodin/zelenina/?ext=2,4,6,11,16&stat=2
      http://www.edb.cz/katalog-firem/zemedelstvi-a-lesnictvi/zahradnictvi/?ext=2,6,11,16,17&stat=2
      http://www.edb.cz/katalog-firem/zemedelstvi-a-lesnictvi/chov-zvirat/?ext=2,6,11,16,17&stat=2
      http://www.edb.cz/katalog-firem/zemedelstvi-a-lesnictvi/semenarstvi/?ext=11,16&stat=2)
  end

  def page_commodity(doc)
    @xpaths[:page][:commodity].each_with_object('') do |xpath, mem|
      value = doc.at_xpath(xpath) || next
      mem << "\n#{to_encode(value.content)}"
    end
  end

  def page_ico(doc)
    doc.xpath(@xpaths[:page][:ico]).each do |node|
      value = to_encode(node.content)
      if value =~ /IČ: (\d+)/
        return Regexp.last_match(1)
      else
        next
      end
    end
  end

  def get_value(*args)
    value = super || (return nil)
    to_encode(value)
  end
end
