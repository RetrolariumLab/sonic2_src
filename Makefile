.DEFAULT_GOAL := help
PYTHON ?= python
REV ?=
ROM_DIR ?=
RUN = $(PYTHON) scripts/run.py

.PHONY: help split check-assets build verify verify-all test check-private-data
help:
	@$(PYTHON) -c "print('Sonic the Hedgehog 2 source reconstruction\n\n  split ROM_DIR=folder  Import your verified ROMs and extract private assets\n  check-assets         Check extracted asset hashes\n  build REV=rev01      Build one original revision\n  verify REV=rev01     Build and compare every byte with your ROM\n  verify-all           Build and compare all accepted revisions\n  test                 Run tests without requiring ROMs\n  check-private-data   Audit tracked files and reachable history')"
split:
	$(RUN) build.assets split $(if $(ROM_DIR),--rom-dir "$(ROM_DIR)")
check-assets:
	$(RUN) build.assets check
build:
	$(RUN) build.build_rom build $(if $(REV),--revision $(REV))
verify:
	$(RUN) build.build_rom verify $(if $(REV),--revision $(REV))
verify-all:
	$(RUN) build.build_rom verify-all
test:
	$(PYTHON) -m unittest discover -s tests
check-private-data:
	$(RUN) validation.private_data
