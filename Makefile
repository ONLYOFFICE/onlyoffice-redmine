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

.PHONY: all
all: # Create an artifact with all preludes.
all: submodule install type lint test build artifact

.PHONY: artifact
artifact: # Create an artifact.
	@tar \
		--directory .build \
		--file onlyoffice_redmine.tar.zst \
		--use-compress-program zstd \
		--create \
		--verbose \
		onlyoffice_redmine

.PHONY: build
build: # Build the plugin.
	@mkdir -p .build/onlyoffice_redmine
	@cp -r \
		app \
		assets \
		config \
		db \
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

.PHONY: help
help: # Show help information.
	@grep --extended-regexp "^[a-z-]+: #" "$(MAKEFILE_LIST)" | \
		awk 'BEGIN {FS = ": # "}; {printf "%-10s  %s\n", $$1, $$2}'

.PHONY: install
install: # Install development dependencies.
ifeq ($(CI),true)
# Disable installation due to cache usage.
else
	@bundle install
endif
ifeq ($(SORBET_SUPPORTED),1)
	@bundle exec tapioca init
else
	@echo "Sorbet isn't supported. Sorbet installation has been skipped."
endif

.PHONY: lint
lint: # Lint for the style.
	@bundle exec rubocop

.PHONY: notes
notes: # Generate release notes.
	@awk '/## [0-9]/{p++} p; /## [0-9]/{if (p > 1) exit}' CHANGELOG.md | \
		awk 'NR>2 {print last} {last=$$0}'

.PHONY: readme-formats
readme-formats: # Generate the formats table in README.md
	@bundle exec rake readme_formats

.PHONY: restart
restart: # Restart the Redmine with plugin containers.
	@docker-compose stop redmine onlyoffice-redmine
	@docker-compose rm --force redmine onlyoffice-redmine
	@docker volume rm onlyoffice-redmine_onlyoffice-redmine
	@docker-compose up --build --detach redmine onlyoffice-redmine
	@docker-compose restart nginx

.PHONY: submodule
submodule: # Update submodules.
	@git submodule update --init --recursive

.PHONY: test
test: # Test the plugin.
	@bundle exec rake test

.PHONY: type
type: # Check for type safety.
ifeq ($(SORBET_SUPPORTED),1)
	@bundle exec srb tc
else
	@echo "Sorbet isn't supported. The type check has been cancelled."
	@exit 1
endif

.PHONY: up
up: # Build and up containers in deatach.
	@docker-compose up --build --detach

.PHONY: version
version: # Show a plugin version.
	@bundle exec rake version
