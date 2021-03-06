$:.unshift(File.expand_path('../../lib', __FILE__))

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require 'plucky'

require 'fileutils'
require 'logger'
require 'pp'

log_dir = File.expand_path('../../log', __FILE__)
FileUtils.mkdir_p(log_dir)
Log = Logger.new(File.join(log_dir, 'test.log'))

LogBuddy.init :logger => Log

connection = Mongo::Connection.new('127.0.0.1', 27017, :logger => Log)
DB = connection.db('test')

RSpec.configure do |config|
  config.filter_run :focused => true
  config.alias_example_to :fit, :focused => true
  config.alias_example_to :xit, :pending => true
  config.run_all_when_everything_filtered = true

  config.before(:suite) do
    DB.collections.map do |collection|
      collection.drop_indexes
    end
  end

  config.before(:each) do
    DB.collections.map do |collection|
      collection.remove
    end
  end
end

operators = %w{gt lt gte lte ne in nin mod all size exists}
operators.delete('size') if RUBY_VERSION >= '1.9.1'
SymbolOperators = operators
