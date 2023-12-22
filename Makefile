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
help: #       Show help information.
	@grep --extended-regexp "^[a-z-]+: #" $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ": # "}; {printf "%s: %s\n", $$1, $$2}'

.PHONY: all
all: #        Create an artifact with all preludes.
all: submodule install type lint test build artifact

.PHONY: submodule
submodule: #  Update submodules.
	@git submodule update --init --recursive

.PHONY: install
install: #    Install development dependencies.
	@bundle install
ifeq ($(SORBET_SUPPORTED),1)
	@bundle exec tapioca init
else
	@echo "Sorbet isn't supported. Sorbet installation has been skipped."
endif

.PHONY: type
type: #       Check for type safety.
ifeq ($(SORBET_SUPPORTED),1)
	@bundle exec srb tc
else
	@echo "Sorbet isn't supported. The type check has been cancelled."
	@exit 1
endif

.PHONY: lint
lint: #       Lint for the style.
	@bundle exec rubocop --fail-level E

.PHONY: test
test: #       Test the plugin.
	@bundle exec rake test

.PHONY: build
build: #      Build the plugin.
	@mkdir -p .build/onlyoffice_redmine
	@cp -r \
		app \
		assets \
		config \
		lib \
		lib2 \
		licenses \
		3rd-Party.license \
		AUTHORS.md \
		CHANGELOG.md \
		init.rb \
		LICENSE \
		README.md \
		.build/onlyoffice_redmine
	@cp Gemfile.prod .build/onlyoffice_redmine/Gemfile
	@find .build/onlyoffice_redmine -name .git -delete

.PHONY: artifact
artifact: #   Create an artifact.
	@tar \
		--directory .build \
		--file onlyoffice_redmine.tar.zst \
		--use-compress-program zstd \
		--create \
		--verbose \
		onlyoffice_redmine

.PHONY: version
version: #    Show a plugin version.
	@bundle exec rake version

.PHONY: notes
notes: #      Generate release notes.
	@awk '/## [0-9]/{p++} p; /## [0-9]/{if (p > 1) exit}' CHANGELOG.md | \
		awk 'NR>2 {print last} {last=$$0}'
