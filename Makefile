.DEFAULT_GOAL := help
PYTHON ?= python
export PYTHONDONTWRITEBYTECODE := 1
REV ?=
ROM_DIR ?=
RUN = $(PYTHON) scripts/run.py

.PHONY: build-relocated runtime-check runtime-golden help split check-assets build verify verify-all test check-private-data lint format format-check
help:
	@$(PYTHON) -c "print('Sonic the Hedgehog 2 source reconstruction\n\n  split ROM_DIR=folder  Import your verified ROMs and extract private assets\n  check-assets         Check extracted asset hashes\n  build REV=rev01      Build one original revision\n  verify REV=rev01     Build and compare every byte with your ROM\n  verify-all           Build and compare all accepted revisions\n  test                 Run tests without requiring ROMs\n  lint                 Check source, text and code style without source edits\n  format               Apply the shared formatters and run lint\n  format-check         Check formatting without source edits\n  release-check        Run the complete preservation guarantee set\n  pointer-audit        Check symbolic pointers and fixed regions\n  build-relocated      Build unreachable-return probes for all revisions\n  runtime-check        Check complete original RAM goldens in MAME\n  runtime-golden       Recapture goldens from verified original inputs\n  check-private-data   Audit tracked files and reachable history\n  source-1-check       Alias for the complete preservation gate\n  release-audit        Audit release ownership, privacy and a clean tree\n  check-stop-words     Audit every reachable ref through Core')"
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

lint:
	$(RUN) validation.lint_project lint
format:
	$(RUN) validation.lint_project format
format-check: lint

build-relocated:
	$(RUN) build.relocate $(if $(REV),--revision $(REV),--all)
runtime-check:
	$(RUN) runtime.movies check $(if $(REV),--revision $(REV))
runtime-golden:
	$(RUN) runtime.movies golden $(if $(REV),--revision $(REV))

.PHONY: pointer-audit source-1-check release-check release-audit check-stop-words
pointer-audit:
	$(RUN) validation.pointers
source-1-check release-check:
	$(RUN) validation.source1
release-audit:
	$(RUN) validation.release_audit --clean
check-stop-words:
	$(PYTHON) -m retrolarium_core.stop_words history "$(CURDIR)" --all
