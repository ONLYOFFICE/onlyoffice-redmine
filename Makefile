.DEFAULT_GOAL := help

ifeq ($(OS),Windows_NT)
	SORBET_SUPPORTED := 0
else
	NAME := $(shell uname -s)
	ifeq ($(NAME),Darwin)
		SORBET_SUPPORTED := 1
	else
		ARCH := $(shell uname -p)
		ifeq ($(ARCH),x86_64)
			SORBET_SUPPORTED := 1
		else
			SORBET_SUPPORTED := 0
		endif
	endif
endif

.PHONY: help
help: #     Show help information.
	@grep --extended-regexp "^[a-z-]+: #" $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ": # "}; {printf "%s: %s\n", $$1, $$2}'

.PHONY: install
install: #  Install development dependencies.
	@bundle install
ifeq ($(SORBET_SUPPORTED),1)
	@bundle exec tapioca init
else
	@echo "Sorbet isn't supported. Sorbet installation has been skipped."
endif

.PHONY: type
type: #     Check for type safety.
ifeq ($(SORBET_SUPPORTED),1)
	@bundle exec srb tc
else
	@echo "Sorbet isn't supported. The type check has been cancelled."
	@exit 1
endif

.PHONY: lint
lint: #     Lint for the style.
	@bundle exec rubocop

.PHONY: test
test: #     Test the plugin.
	@bundle exec rake test
