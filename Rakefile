$:.unshift(File.dirname(__FILE__))
require 'rake/testtask'
require 'lib/libwebsocket'

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/test_*.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "libwebsocket"
    gemspec.version = LibWebSocket::VERSION
    gemspec.summary = "Universal Ruby library to handle WebSocket protocol"
    gemspec.description = "Universal Ruby library to handle WebSocket protocol"
    gemspec.email = "bernard.potocki@imanel.org"
    gemspec.homepage = "http://github.com/imanel/libwebsocket"
    gemspec.authors = ["Bernard Potocki"]
    gemspec.files.exclude ".gitignore"
    gemspec.add_dependency "addressable"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
