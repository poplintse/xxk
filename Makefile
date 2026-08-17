SHELL := /bin/bash

.PHONY: help \
	build-ios-debug build-ios-release \
	build-android-debug build-android-release \
	build-macos-debug build-macos-release \
	build-windows-debug build-windows-release \
	build-backend-release build-web-release

help:
	@printf '%s\n' \
		'make build-macos-release VERSION=0.3.0  Build a locally signed macOS release' \
		'make build-macos-debug VERSION=0.3.0    Build a locally signed macOS debug app' \
		'make build-ios-release VERSION=0.3.0    Build iOS when its project exists' \
		'make build-android-release VERSION=0.3.0 Build Android when its project exists' \
		'make build-windows-release VERSION=0.3.0 Build Windows when its project exists' \
		'make build-web-release VERSION=0.3.0    Build Web when its project exists'

build-ios-debug:
	@VERSION="$(VERSION)" ./scripts/build-ios-debug.sh

build-ios-release:
	@VERSION="$(VERSION)" ./scripts/build-ios-release.sh

build-android-debug:
	@VERSION="$(VERSION)" ./scripts/build-android-debug.sh

build-android-release:
	@VERSION="$(VERSION)" ./scripts/build-android-release.sh

build-macos-debug:
	@VERSION="$(VERSION)" ./scripts/build-macos-debug.sh

build-macos-release:
	@VERSION="$(VERSION)" ./scripts/build-macos-release.sh

build-windows-debug:
	@VERSION="$(VERSION)" ./scripts/build-windows-debug.sh

build-windows-release:
	@VERSION="$(VERSION)" ./scripts/build-windows-release.sh

build-backend-release:
	@VERSION="$(VERSION)" ./scripts/build-backend-release.sh

build-web-release:
	@VERSION="$(VERSION)" ./scripts/build-web-release.sh
