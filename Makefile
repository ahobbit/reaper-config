.PHONY: help test diff pull apply build clean hook

help:
	@echo "REAPER Configuration Developer Commands:"
	@echo "  make test    - Run verification and integrity suite"
	@echo "  make diff    - Compare live REAPER settings vs tracked repo profile"
	@echo "  make pull    - Sync and sanitize live REAPER settings into repo"
	@echo "  make apply   - Apply repo configuration to live REAPER (with backup)"
	@echo "  make build   - Package distribution ZIP bundles locally"
	@echo "  make clean   - Clean dist/ and temporary caches"
	@echo "  make hook    - Install git pre-commit safety hook"

test:
	@./dev test

diff:
	@./dev diff

pull:
	@./dev pull

apply:
	@./dev apply

build:
	@./dev build

clean:
	@./dev clean

hook:
	@./dev install-hook
