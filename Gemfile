# Please ensure that the dependencies are kept at the same versions as the
# Redmine team.
#
# https://github.com/redmine/redmine/blob/master/Gemfile

source "https://rubygems.org"

gem "i18n", "~> 1.10.0"
gem "rails", "= 6.1.4.7"
gem "render_parent", "~> 0.1.0"
gem "sorbet-runtime", "~> 0.5.10969"

group :development, :test do
  gem "rake", "~> 13.0"

  # Unfortunately, Sorbet only supports Darwin and Linux-based systems.
  # Additionally, it doesn't support Linux on ARM64, which may be used in a
  # Docker VM on Mac, for example.
  #
  # https://github.com/sorbet/sorbet/issues/4011
  # https://github.com/sorbet/sorbet/issues/4119
  install_if -> { RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /x86_64/ } do
    gem "sorbet", "~> 0.5.10969"
    gem "tapioca", "~> 0.11.8"
  end
end

group :test do
  gem "minitest", "~> 5.19"
  gem "rubocop", "~> 1.56"
  gem "rubocop-minitest", "~> 0.31.0"
  gem "rubocop-rails", "~> 2.20"
  gem "rubocop-rake", "~> 0.6.0"
  gem "rubocop-sorbet", "~> 0.7.2"
end
