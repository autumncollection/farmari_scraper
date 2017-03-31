require 'common'

class VeronicaCz < Common
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
    @folder = 'veronica_cz'
    super
  end

  def find_categories
    %w(http://www.veronica.cz/ekomapa)
  end

  def find_urls(categories)
    doc = Nokogiri::HTML(request('http://www.veronica.cz/ekomapa'))
    doc.xpath('//ul[@id="okruh_2"]//a/@id').map do |url|
      id = url.content =~ /(\d+)/ ? Regexp.last_match(1) : nil
      next unless id
      "http://www.veronica.cz/lib/ekomapa_ajax.php?kategorie=#{id}&region=0"
    end.compact
  end

  def process_url(url)
    response = request(url) || (return nil)
    doc = Nokogiri::XML(response)
    doc.xpath('//objekt').map do |node|
      infobox = node.at_xpath('./infobox') || next
      infobox = infobox.content
      url     = infobox =~ /posli_o\('(.+)'\)/i ? Regexp.last_match(1) : nil
      web     = infobox =~ %r{href=\"(http://.+?)\"} ? Regexp.last_match(1) : nil
      email   = infobox =~ /\"mailto:(.+?)\"/ ? Regexp.last_match(1) : nil
      telefon = infobox =~ /telefon: ([\d\s]+)/ ? Regexp.last_match(1).strip : nil
      obec    = node.at_xpath('obec') ? node.at_xpath('obec').content : nil
      commodity  = node.at_xpath('commodity') ? node.at_xpath('commodity').content : nil
      {
        url: "http://veronica.cz/ekomapa##{url}",
        name: node.at_xpath('jmeno').content,
        info: infobox,
        tel: telefon,
        web: web,
        email: email,
        street: node.at_xpath('ulice').content,
        region: url =~ /r=(.+?)&/ ? Regexp.last_match(1) : nil,
        city: obec,
        commodity: commodity
      }
    end
  rescue => error
    p " - #{error.message} #{error.backtrace}"
    @errors << { url: url, error: "#{error.message} #{error.backtrace}" }
    []
  end
end
