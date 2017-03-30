# encoding:utf-8
require 'rspec'
require 'pry'
$LOAD_PATH << File.join(__dir__, '..', 'sources')
ENV['RACK_ENV'] = 'test'

module RSpecMixin
end

RSpec.configure { |c| c.include RSpecMixin }
