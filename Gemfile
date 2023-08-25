source "https://rubygems.org"

gem "minitest", "~> 5.19", group: :test
gem "rails", "= 5.2.8.1"
gem "rake", "~> 13.0", groups: %i[development test]
gem "render_parent", "~> 0.1.0"
gem "rubocop", "~> 1.56", group: :test
gem "rubocop-minitest", "~> 0.31.0", group: :test
gem "rubocop-rails", "~> 2.20", group: :test
gem "rubocop-rake", "~> 0.6.0", group: :test
gem "rubocop-sorbet", "~> 0.7.2", group: :test
gem "sorbet-runtime", "~> 0.5.10969"

# Unfortunately, Sorbet only supports Darwin and Linux-based systems.
# Additionally, it doesn't support Linux on ARM64, which may be used in a Docker
# VM on Mac, for example.
#
# https://github.com/sorbet/sorbet/issues/4011
# https://github.com/sorbet/sorbet/issues/4119
install_if -> { RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /x86_64/ } do
  gem "sorbet", "~> 0.5.10969", groups: %i[development test]
  gem "tapioca", "~> 0.11.8", groups: %i[development test]
end
