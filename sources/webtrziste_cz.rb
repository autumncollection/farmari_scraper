require 'common'

class WebtrzisteCz < Common
  ENCODE = { from: 'utf-8', to: 'windows-1250' }
  XPATHS = {
    urls_items: '//table[@id="remeslnici"]//td[contains(@onclick,"ZobrazitNahled")]/@onclick',
    base_doc: '//div[@id="obsah"]',
    page: {
      name: './/tr[./td/img[@title[contains(.,"Kontaktní")]]]/td[last()]',
      street: './/tr[./td/img[@title[contains(.,"Adresa")]]]/td[last()]',
      zip: './/tr[./td/img[@title[contains(.,"Adresa")]]]/td[last()]',
      city: './/tr[./td/img[@title[contains(.,"Adresa")]]]/td[last()]',
      region: './/tr[./td/img[@title[contains(.,"Adresa")]]]/td[last()]',
      tel: './/tr[./td/img[@title[contains(.,"telefon")]]]/td[last()]',
      web: './/tr[./td/img[@title[contains(.,"web")]]]/td[last()]//span/@title',
      commodity: './/span[@class="doplnek"][contains(.,"emeslu")]/following-sibling::p[1]',
      trhy: './/td[@class="popis"][contains(., "na trhy")]/following-sibling::td[1]/img/@src'
    }
  }
  def initialize
    @folder = 'webtrziste_cz'
    super
  end

  def find_categories
    ['http://webtrziste.cz/trhy/remesla/seznam/?clear_filter=1']
  end

  def parse_url(node)
    node.value =~ /\((\d+)\)/
    "http://webtrziste.cz/trhy/remesla/nahled.php?id=#{Regexp.last_match(1)}"
  end

  def page_street(doc)
    value = get_page_value(doc, :street) || (return nil)
    value.split("\n")[1]
  end

  def page_zip(doc)
    value = get_page_value(doc, :zip) || (return nil)
    value = value.split("\n")[2]
    value =~ /(\d+)/ ? Regexp.last_match(1) : value
  end

  def page_city(doc)
    value = get_page_value(doc, :city) || (return nil)
    value = value.split("\n")[2]
    value =~ /\d+\s-(.+)\z/ ? Regexp.last_match(1) : value
  end

  def page_region(doc)
    value = get_page_value(doc, :region) || (return nil)
    value.split("\t")[-2]
  end

  def page_trhy(doc)
    value = get_page_value(doc, :trhy) || (return nil)
    value =~ /ok/ ? 'ano' : 'ne'
  end

  def clean_value!(value)
    value.tr!('Â', '')
    value.squeeze!(' ')
    value
  end
end
