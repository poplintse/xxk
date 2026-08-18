SHELL := /bin/bash

.PHONY: help \
	set-macos-version set-macos-build-number \
	build-ios-debug build-ios-release \
	build-android-debug build-android-release \
	build-macos-debug build-macos-release \
	build-windows-debug build-windows-release \
	build-backend-release build-web-release

help:
	@printf '%s\n' \
		'make set-macos-version VERSION=0.3.0    Set the macOS release version' \
		'make set-macos-build-number BUILD_NUMBER=9 Set the macOS build number' \
		'make build-macos-release                Build a locally signed macOS release' \
		'make build-macos-debug                  Build a locally signed macOS debug app' \
		'make build-ios-release VERSION=0.3.0    Build iOS when its project exists' \
		'make build-android-release VERSION=0.3.0 Build Android when its project exists' \
		'make build-windows-release VERSION=0.3.0 Build Windows when its project exists' \
		'make build-web-release VERSION=0.3.0    Build Web when its project exists'

set-macos-version:
	@version="$(VERSION)"; \
	[[ "$$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$$ ]] || { echo "VERSION must be semantic, for example 0.3.0" >&2; exit 2; }; \
	printf '%s\n' "$$version" > apps/macos/VERSION; \
	echo "macOS version set to $$version"

set-macos-build-number:
	@build_number="$(BUILD_NUMBER)"; \
	[[ "$$build_number" =~ ^[1-9][0-9]*$$ ]] || { echo "BUILD_NUMBER must be a positive integer, for example 9" >&2; exit 2; }; \
	printf '%s\n' "$$build_number" > apps/macos/BUILD_NUMBER; \
	echo "macOS build number set to $$build_number"

build-ios-debug:
	@VERSION="$(VERSION)" ./scripts/build-ios-debug.sh

build-ios-release:
	@VERSION="$(VERSION)" ./scripts/build-ios-release.sh

build-android-debug:
	@VERSION="$(VERSION)" ./scripts/build-android-debug.sh

build-android-release:
	@VERSION="$(VERSION)" ./scripts/build-android-release.sh

build-macos-debug:
	@VERSION="$(VERSION)" BUILD_NUMBER="$(BUILD_NUMBER)" ./scripts/build-macos-debug.sh

build-macos-release:
	@VERSION="$(VERSION)" BUILD_NUMBER="$(BUILD_NUMBER)" ./scripts/build-macos-release.sh

build-windows-debug:
	@VERSION="$(VERSION)" ./scripts/build-windows-debug.sh

build-windows-release:
	@VERSION="$(VERSION)" ./scripts/build-windows-release.sh

build-backend-release:
	@VERSION="$(VERSION)" ./scripts/build-backend-release.sh

build-web-release:
	@VERSION="$(VERSION)" ./scripts/build-web-release.sh
