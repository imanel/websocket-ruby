# frozen_string_literal: true

source 'https://rubygems.org'

running_ruby_version = Gem::Version.new(RUBY_VERSION)

group :development do
  gem 'bundler-audit', '~> 0.9', require: false
  gem 'rake'
  gem 'rspec', '~> 3.13'
  gem 'webrick'

  # rubocop/rubocop-rspec 1.88.x/3.10.x require Ruby >= 2.7; the test matrix
  # goes back to Ruby 2.1, so these are dev-lint-only and gated to keep
  # `bundle install` working on every Ruby the test suite still supports.
  if running_ruby_version >= Gem::Version.new('2.7')
    gem 'rubocop', '~> 1.88', require: false
    gem 'rubocop-rspec', '~> 3.10', require: false
  end

  # simplecov 1.0.x requires Ruby >= 3.2; gated for the same reason as above.
  gem 'simplecov', '~> 1.0', require: false if running_ruby_version >= Gem::Version.new('3.2')
end

gemspec
