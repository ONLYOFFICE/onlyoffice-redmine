source 'https://rubygems.org'

gem "render_parent", "~> 0.1.0"
gem "rails", "= 5.2.8.1"
gem "rubocop", "~> 1.56", :group => :test
gem "rubocop-rails", "~> 2.20", :group => :test
gem "rubocop-sorbet", "~> 0.7.2", :group => :test
gem "sorbet-runtime", "~> 0.5.10969"

# Unfortunately, Sorbet only supports Darwin and Linux-based systems.
# Additionally, it doesn't support Linux on ARM64, which may be used in a Docker
# VM on Mac, for example.
#
# https://github.com/sorbet/sorbet/issues/4011
# https://github.com/sorbet/sorbet/issues/4119
install_if -> { RUBY_PLATFORM =~ /darwin/ || RUBY_PLATFORM =~ /x86_64/ } do
  gem "sorbet", "~> 0.5.10969", :groups => [:development, :test]
  gem "tapioca", "~> 0.11.8", :groups => [:development, :test]
end
