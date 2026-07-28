# frozen_string_literal: true

begin
  require 'simplecov'
  SimpleCov.start do
    skip '/spec/'
    enable_coverage :branch
    minimum_coverage line: 100, branch: 100
  end
rescue LoadError
  # simplecov requires Ruby >= 3.2 and isn't installed on older Rubies
  # (see Gemfile) — the suite still runs, just without coverage enforcement.
end

require 'rspec'

require 'websocket'
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.before(:suite) do
    WebSocket.max_frame_size = 100 * 1024 # 100kb
  end
end
