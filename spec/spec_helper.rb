require 'bundler/setup'
require 'simplecov'
require 'simplecov-console'
require 'byebug'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console
]

SimpleCov.start do
  add_filter '/spec/'
end

require 'mahuta'

SPEC_SAMPLE_SCHEMA = Mahuta::Schema.new do
  type :root do
    def one!(attributes = {}, &block)
      add_child(:one, attributes, &block)
    end
  end
  type :one do
    def one!(attributes = {}, &block)
      add_child(:one, attributes, &block)
    end
    def two!(attributes = {}, &block)
      add_child(:two, attributes, &block)
    end
  end
  type :two do
    def three!(attributes = {}, &block)
      add_child(:three, attributes, &block)
    end
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
