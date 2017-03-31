require 'common'

class FarmarNaDlaniCz < Common
  # UA_PARAMS = { timeout: 10 }
  XPATHS = {
    base_doc: '//body',
    page: {
      name: './/h1',
      street: './/h3/following-sibling::div[2]',
      city: './/div[@class="name"]/h3',
      web: './/a[@class="btn-website"]/@href',
      info: './/div[@class="farmerDescription"]' }
  }
  def initialize
    @folder = 'farmarnadlani_cz'
    super
  end

  def process_url(url)
    unless defined?(@in_categories)
      parse_urls(Nokogiri::HTML(request('https://farmanadlani.cz/homepage/iframe')))
    end

    response = request(url) || (return nil)
    docs = base_doc(Nokogiri::HTML(response))
    data = docs.map do |doc|
      data = @xpaths[:page].keys.each_with_object(url: url) do |key, mem|
        mem[key] =
          if respond_to?("page_#{key}".to_sym)
            send("page_#{key}", doc)
          else
            get_page_value(doc, key)
          end
      end
      id = url =~ /(\d+)\z/ ? Regexp.last_match(1) : nil
      data[:categories] = @in_categories[id]
      doc.to_s =~ /address:\s+\"(.+?)\"\s+\+\s+\",\s+\"\+\s+\"(.+?)\"\s+\+\s+\",\s+\"\+\s+(\d+)/
      [:street, :city, :zip].each_with_index do |key, index|
        data[key] = Regexp.last_match(index + 1)
      end
      data
    end
    clean_data(data) do |value|
      clean_value!(value)
    end
  rescue => error
    p " - #{error.message} #{error.backtrace}"
    @errors << { url: url, error: "#{error.message} #{error.backtrace}" }
    []
  end

  def find_categories
  %w(
    https://farmanadlani.cz/homepage/iframe)
  end

  def parse_urls(doc)
    @in_categories = doc.xpath('//button[contains(@onclick, "filterMarkers")]').each_with_object({}) do |button, mem|
      id = button.at_xpath('./@onclick').content =~ /(-?\d+)/ ? Regexp.last_match(1) : nil
      mem[id] = button.content
    end

    categories = doc.to_s.scan(/category: (\d+)/).flatten.map do |category|
      category
    end
    index = 0
    doc.to_s.scan(/url_slug:\s+"(.+?)"/).flatten.map do |url|
      index += 1
      "http://trziste.farmanadlani.cz/farm/detail/#{url}##{categories[index - 1]}"
    end
  end
end
