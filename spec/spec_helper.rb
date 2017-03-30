# encoding:utf-8
require 'rspec'
require 'pry'
$LOAD_PATH << File.join(__dir__, '..', 'sources')
require 'common'
Dir[File.join(__dir__, '../sources/*.rb')].each do |f|
  file =  f.split('/')[-1].sub('.rb', '')
  next if file == 'common'
  require file
end
ENV['RACK_ENV'] = 'test'

module RSpecMixin
end

RSpec.configure { |c| c.include RSpecMixin }
