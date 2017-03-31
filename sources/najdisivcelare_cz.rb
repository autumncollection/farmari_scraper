require 'common'

class NajdiSiVcelareCz < Common
  # UA_PARAMS = { timeout: 10 }
  XPATHS = {
    urls_items: '//ul[contains(@class,"product_list")]//a[@class="product-name"]/@href',
    urls_paging: '//div[@id="pagination"]//li[@id="pagination_next"]/a/@href',
    base_doc: '//div[@id="center_column"]',
    page: {
      name: './/h1',
      street: '//div[@id="short_description_content"]/p[2]//br[last()]/preceding-sibling::text()[1]',
      city:   '//div[@id="short_description_content"]/p[2]//span[last()]',
      zip:    '//div[@id="short_description_content"]/p[2]',
      region: './/div[contains(text(),"Region")]/a',
      email: './/div[@id="short_description_content"]//a[contains(@href, "mailto")]',
      tel: './/div[@id="short_description_content"]//p[contains(., "tel")]',
      info: './/div[@id="divInfo"]//p[contains(., "Okres")]',
      web: './/div[@id="short_description_content"]//p//a/@href',
      commodity: './/table[@class="table-data-sheet"]//tr'    }
  }
  def initialize
    @folder = 'najdisivcelare_cz'
    super
  end

  def parse_url(node)
    node.content
  end

  def page_commodity(doc)
    doc.xpath(@xpaths[:page][:commodity]).map do |node|
      "#{node.at_xpath('./td[1]').content}=#{node.at_xpath('./td[2]').content}"
    end.join(', ')
  end

  def page_zip(doc)
    value = get_page_value(doc, :zip)
    value =~ /(\d\d\d\s?\d\d)/ ? Regexp.last_match(1).gsub(' ', '') : nil
  end

  def page_city(doc)
    value = get_page_value(doc, :zip)
    value =~ /[\d\d\d\s?\d\d]+[[:space:]]+(.+)/ ? Regexp.last_match(1).strip : nil
  end

  def parse_url_paging(url, category_url)
    "https://www.najdisivcelare.cz#{url}"
  end

  def page_tel(doc)
    value = get_page_value(doc, :tel) || (return nil)
    value.strip!
    value =~ /tel:[[:space:]]([[[:space]]\s\d]+)/ ? Regexp.last_match(1) : nil
  end

  def find_categories
    doc = Nokogiri::HTML(request('https://www.najdisivcelare.cz/'))
    doc.xpath('//div[@id="categories_block_left"]//a[contains(@href,"kraj")]/@href').map do |url|
      url.content
    end
  end
end
