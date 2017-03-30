require 'common'

class OvocnarskaUnieCz < Common
  XPATHS = {
    urls_items: '//a[contains(@class,"neklient")]/@href',
    base_doc: '//table[@id="table"]//tr[not(@class="zahl")]',
    page: {
      name: './td[1]/b/span/following-sibling::text()',
      street: './td[1]/span[@class="adresa"]',
      zip: './td[1]/span[@class="adresa"]',
      city: './td[1]/span[@class="adresa"]',
      mobile: './td[2]',
      tel: './td[2]',
      email: './td[2]',
      web: './td[2]/a/@href',
      commodity: './td[3]'
    }
  }
  def initialize
    @folder = 'ovocnarska_unie_cz'
    super
  end

  def find_categories
    %w(http://www.ovocnarska-unie.cz/index.php?page=1911 )
  end

  def parse_url(node)
    "http://www.ovocnarska-unie.cz/index.php?#{node.content}"
  end

  def page_mobile(doc)
    value = get_page_value(doc, :mobile) || (return nil)
    value =~ /mob.\s([\d\s]+)/ ? Regexp.last_match(1) : nil
  end

  def page_tel(doc)
    value = get_page_value(doc, :tel) || (return nil)
    value =~ /tel.\s([\d\s]+)/ ? Regexp.last_match(1) : nil
  end

  def page_email(doc)
    value = get_page_value(doc, :email) || (return nil)
    value =~ /e-mail:\s(.+)/ ? Regexp.last_match(1) : nil
  end

  def page_street(doc)
    value = get_page_value(doc, :street) || (return nil)
    value =~ /([\s\S]+),/ ? Regexp.last_match(1) : value
  end

  def page_zip(doc)
    value = get_page_value(doc, :zip) || (return nil)
    value =~ /,\s?(\d+\s\d+)/ ? Regexp.last_match(1) : value
  end

  def page_city(doc)
    value = get_page_value(doc, :city) || (return nil)
    value =~ /,\s?\d+\s\d+\s([\s\S]+)/ ? Regexp.last_match(1) : value
  end
end
