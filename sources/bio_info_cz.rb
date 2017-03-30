require 'common'

class BioInfoCz < Common
  # UA_PARAMS = { timeout: 10 }
  URL = 'http://www.bio-info.cz'
  XPATHS = {
    urls_items: '//div[@id="article"]//ul/li[contains(@class,"item")]/a/@href',
    urls_paging: '//div[@id="article"]//div[@class="pager"]/span' \
      '/following-sibling::a[1]/@href',
    base_doc: '//div[@id="article"]',
    page: {
      name: './h2',
      street: './/div[@class="article-content"]/div/h4[contains(text(),"Adresa")]/' \
        'following-sibling::p[1]',
      city: './/div[@class="article-content"]/div/h4[contains(text(),"Adresa")]/' \
        'following-sibling::p[2]',
      zip: './/div[@class="article-content"]/div/h4[contains(text(),"Adresa")]/' \
        'following-sibling::p[2]',
      region: './/div[@class="article-content"]/div/p[contains(.,"Kraj")]/text()',
      tel: './/div[@class="article-content"]/div/h4[contains(text(),"Telefon")]/' \
        'following-sibling::p[1]',
      email: './/div[@class="article-content"]/div/h4[contains(text(),"E-mail")]/' \
        'following-sibling::p[1]',
      web: './/div[@class="article-content"]/div/h4[contains(text(),"Web")]/' \
        'following-sibling::p[1]',
      info: './/div[@class="article-content"]/div/h4[contains(text(),"Popis společnosti")]/' \
        'following-sibling::p[1]',
      commodity: ''
    }
  }
  def initialize
    @folder = 'bio_info_cz'
    super
  end

  def parse_url(node)
    "#{node.content}"
  end

  def parse_url_paging(url, _)
    "#{URL}#{url}"
  end

  def find_categories
    %w(
      http://www.bio-info.cz/seznamy/firmy/vyrobci
      http://www.bio-info.cz/seznamy/firmy/zemedelci)
  end

  def page_commodity(doc)
    data = doc.xpath('.//div[@class="article-content"]/div/h4[contains(text(),"Produktové kategorie")]/' \
        'following-sibling::*').each_with_object([]) do |node, mem|
      break mem if node.name != 'p'
      mem << node.content
    end
    doc.xpath('.//div[@class="article-content"]/div/h4[contains(text(),"V současnosti nabízené")]/' \
        'following-sibling::*').each_with_object(data) do |node, mem|
      break mem if node.name != 'p'
      mem << node.content
    end.join(', ')
  end

  def page_zip(doc)
    value = get_page_value(doc, :zip) || (return nil)
    value =~ /([\d\s]+)/ ? Regexp.last_match(1) : nil
  end

  def page_city(doc)
    value = get_page_value(doc, :zip) || (return nil)
    value =~ /[\d\s]+\s(.+)/ ? Regexp.last_match(1) : nil
  end

  def clean_value!(value)
    value.gsub!(/.+/, '') if !value.blank? && value =~ /\Aaaa\z/i
  end
end
