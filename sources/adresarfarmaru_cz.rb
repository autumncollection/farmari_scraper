require 'common'

class AdresarFarmaruCz < Common
  # UA_PARAMS = { timeout: 10 }
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
    @folder = 'adresarfarmaru_cz'
    super
  end

  def find_categories
  %w(http://www.adresarfarmaru.cz/connector)
  end

  def find_urls(doc)
    doc = Oj.load(request(
      'http://www.adresarfarmaru.cz/connector',
      { method: :post,
      body: { cmd: 'locations' } } ))
    doc.map do |node|
      "http://www.adresarfarmaru.cz/connector##{node['id']}"
    end
  end

  KEYS = {

  }

  def process_url(url)
    id = url =~ /#(\d+)/ ? Regexp.last_match(1) : nil
    return unless id
    response = request(
      url,
      method: :post, body: { cmd: 'detail', locid: id }) || (return nil)
    doc = Oj.load(response)
    return nil unless %w(1 2 6).include?(doc['type_id'])
    {
      url: "http://www.adresarfarmaru.cz/#{doc['alias']}-#{id}",
      name: doc['title'],
      info: doc['description'],
      tel: doc['phone'],
      web: doc['web'],
      email: doc['email'],
      street: doc['street'],
      region: doc['region'],
      city: doc['city'],
      zip: doc['zip'],
      commodity: (doc['productList'] || {}).keys.join(', ')
    }
  rescue => error
    p " - #{error.message} #{error.backtrace}"
    @errors << { url: url, error: "#{error.message} #{error.backtrace}" }
    []
  end
end
