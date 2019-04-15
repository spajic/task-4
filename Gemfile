source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.1'

gem 'rails', '~> 5.2.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

gem 'strong_migrations', '~> 0.3.1'
gem 'oj', '~> 3.7.11'
gem 'activerecord-import', '~> 1.0.1'

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rack-mini-profiler', '~> 1.0.2', require: false
  gem 'memory_profiler', '~> 0.9.13', require: false
  gem 'flamegraph', '~> 0.9.5', require: false
  gem 'stackprof', '~> 0.2.12', require: false
  gem 'ruby-prof', '~> 0.17.0', require: false
  gem 'benchmark-ips', '~> 2.7.2', require: false
  gem 'bullet', '~> 5.9.0'
end

group :test do
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
