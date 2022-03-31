source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.6"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem "rails", "~> 6.0.2"
gem "pg"
gem "puma", "~> 4.3"
gem "bootsnap", ">= 1.4.2", require: false
gem "clearance"
gem "haml-rails"
gem "simple_form"
gem "webpacker", "~> 4.x"
gem "image_processing"
gem "inline_svg"
gem "pundit"
gem "textacular"
gem "aws-sdk-s3"
gem "sidekiq"

group :test do
  gem "shoulda-matchers"
  gem "capybara"
  gem "launchy"
  gem "email_spec"
end

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "standard"
  gem "pry-rails"
end

group :development do
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "annotate"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
