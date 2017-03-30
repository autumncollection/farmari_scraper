require 'typhoeus'
require 'nokogiri'
require 'oj'
require 'hashie'
require 'active_support/all'

class Common
  attr_accessor :categories, :xpaths
  DEFAULT_KEYS = [
    :url,
    :name,
    :street,
    :zip,
    :city,
    :region,
    :tel,
    :mobile,
    :email,
    :web,
    :commodity,
    :trhy
  ]
  def initialize
    @xpaths = self.class::XPATHS
    @ua_params = defined?(self.class::UA_PARAMS) ? self.class::UA_PARAMS : {}
    Dir.mkdir(cache_dir(@folder)) unless File.exist?(cache_dir(@folder))
    @errors = []
  end

  def perform
    @categories = find_categories
    @urls = find_urls(@categories)
    process_urls(@urls)
  end

  def find_urls(categories)
    urls = []
    categories.each do |category_url|
      loop do
        break if category_url.blank?
        doc = request(category_url)
        unless doc
          errors << { error: 'missing doc', category_url: category_url }
          next
        end
        urls.concat(parse_urls(Nokogiri::HTML(doc)))
        category_url = find_urls_paging(doc, category_url) do |url|
          parse_url_paging(url)
        end
      end
    end
    urls.compact.uniq
    urls
  end

  def find_urls_paging(doc, category_url, &block)
    return nil if @xpaths[:urls_paging].blank?
    value = doc.at_xpath(@xpaths[:urls_paging]) || (return nil)
    block.call(value, category_url)
  end

  def parse_url_paging(url, _category_url)
    url.content.to_s
  end

  def parse_urls(doc)
    doc.xpath(@xpaths[:urls_items]).map do |node|
      parse_url(node)
    end
  end

  def process_urls(urls)
    urls.map do |url|
      process_url(url)
    end.compact.flatten
  end

  def base_doc(doc)
    return [doc] if @xpaths[:base_doc].blank?
    doc.xpath(@xpaths[:base_doc])
  end

  def process_url(url)
    response = request(url) || (return nil)
    docs = base_doc(Nokogiri::HTML(response))
    data = docs.map do |doc|
      @xpaths[:page].keys.each_with_object(url: url) do |key, mem|
        mem[key] =
          if respond_to?("page_#{key}".to_sym)
            send("page_#{key}", doc)
          else
            get_page_value(doc, key)
          end
      end
    end
    clean_data(data) do |value|
      clean_value!(value)
    end
  rescue => error
    p " - #{error.message}"
    @errors << { url: url, error: "#{error.message} #{error.backtrace}" }
    []
  end

  def clean_data(data, &block)
    data.each do |item|
      item.each do |_, value|
        next if value.blank?
        value.strip!
        block.call(value) if block_given?
      end
    end
  end

  def clean_value!(value)
  end

  def get_page_value(doc, key)
    get_value(doc, @xpaths[:page][key])
  end

  def get_value(doc, xpath)
    value = doc.at_xpath(xpath)
    value.blank? ? nil : value.content
  end

  def find_categories
  end

  def request(url, params = {}, force = false)
    file = cache_file(url)
    if force || !File.exist?(file)
      response = ua_request(url, params) || (return nil)
      body = response.body
      IO.write(file, body)
      body
    else
      File.read(file)
    end
  end

  def ua_request(url, params = {})
    retries ||= 5
    response = Typhoeus::Request.new(url, @ua_params.merge(
      method: :get, proxy: 'localhost:10000').merge(params)).run
    fail("unsuccess #{response.return_message}") unless response.success?
    response
  rescue => error
    p "#{url} #{error.message}"
    return nil if retries.zero?
    sleep(0.9)
    retries -= 1
    retry
  end

  def cache_file(url)
    digest = Digest::SHA1.hexdigest(url)
    "#{cache_dir(@folder)}#{digest}"
  end

  def cache_dir(sub_dir = '')
    File.join(__dir__, '..', 'cache', "#{sub_dir}/").squeeze('/')
  end
end
