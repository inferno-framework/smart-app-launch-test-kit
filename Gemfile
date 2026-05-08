# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Filler gem paths to tls-test-kit and inferno-core to allow for development without pushing to rubygems.
gem 'inferno_core', git: 'https://github.com/FlexonyoPizza/inferno-core.git', branch: 'main'
gem 'tls_test_kit', git: 'https://github.com/FlexonyoPizza/tls-test-kit.git', branch: 'main'

group :development, :test do
  gem 'debug'
end
