require 'common'

class CeskyFarmarCz < Common
  # UA_PARAMS = { timeout: 10 }
  ENCODE = { from: 'utf-8', to: 'windows-1250' }
  XPATHS = {
    urls_items: '//div[@id="mainbody"]//a[contains(@href,"farmar-detail")]/@href',
    urls_paging: '//div[@id="mainbody"]//p[@class="strankovani"]' \
      '/a[@class="od-strana-active"]/following-sibling::a[1]/@href',
    base_doc: '//div[@class="contentpaneopen "]',
    page: {
      name: './/h3',
      street: './/h3/following-sibling::div[2]',
      city: './/h3/following-sibling::div[3]/text()',
      zip: './/h3/following-sibling::div[3]/strong',
      region: './/div[contains(text(),"Region")]/a',
      mobile: './/div[contains(text(),"Mobil")]',
      email: './/div[contains(text(),"Email")]/a',
      tel: './/div[contains(text(),"Telefon")]',
      info: './/div[@id="divInfo"]//p[contains(., "Okres")]',
      web: './/div[@id="divInfo"]/p/a[contains(@onclick,"neklient+WWW")]/@href',
      commodity: './/div[./u]/text()'    }
  }
  def initialize
    @folder = 'ceskyfarmar_cz'
    super
  end

  def parse_url(node)
    "http://ceskyfarmar.cz#{node.content}"
  end

  def parse_url_paging(url, _)
    "http://ceskyfarmar.cz/#{url}"
  end

  def find_categories
    %w(
      http://ceskyfarmar.cz/farmar-region.php?rid=1
      http://ceskyfarmar.cz/farmar-region.php?rid=2
      http://ceskyfarmar.cz/farmar-region.php?rid=3
      http://ceskyfarmar.cz/farmar-region.php?rid=4
      http://ceskyfarmar.cz/farmar-region.php?rid=5
      http://ceskyfarmar.cz/farmar-region.php?rid=6
      http://ceskyfarmar.cz/farmar-region.php?rid=7
      http://ceskyfarmar.cz/farmar-region.php?rid=8
      http://ceskyfarmar.cz/farmar-region.php?rid=9
      http://ceskyfarmar.cz/farmar-region.php?rid=10
      http://ceskyfarmar.cz/farmar-region.php?rid=11
      http://ceskyfarmar.cz/farmar-region.php?rid=12
      http://ceskyfarmar.cz/farmar-region.php?rid=13
      http://ceskyfarmar.cz/farmar-region.php?rid=14)
  end

  def page_commodity(doc)
    doc.xpath(@xpaths[:page][:commodity]).map do |node|
      node.content
    end.join(', ')
  end

  def page_mobile(doc)
    value = get_page_value(doc, :mobile) || (return nil)
    value =~ /: \+?([\d\s]+)/ ? Regexp.last_match(1).gsub(' ', '') : nil
  end

  def page_tel(doc)
    value = get_page_value(doc, :tel) || (return nil)
    value =~ /: \+?([\d\s]+)/ ? Regexp.last_match(1).gsub(' ', '') : nil
  end
end
