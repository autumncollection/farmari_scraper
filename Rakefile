# encoding:utf-8
$LOAD_PATH << File.join(__dir__, 'sources')
require 'rake'
require 'csv'

namespace :bin do
  task :import do
    require_relative 'sources'
    require 'common'
    if ENV['SOURCES']
      ENV['SOURCES'].split(';').each do |source|
        value = SOURCES[source] || next
        require value[:file]
        klass = Object.const_get(value[:klass]).new
        data  = klass.perform
        string = CSV.generate do |csv|
          data.each do |row|
            csv << row.values_at(*Common::DEFAULT_KEYS)
          end
        end
        IO.write(File.join(__dir__, 'data', "#{source}.csv"), string)
      end
    end
  end
end
