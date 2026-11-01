.DEFAULT_GOAL := help
PYTHON ?= python
export PYTHONDONTWRITEBYTECODE := 1
REV ?=
ROM_DIR ?=
RUN = $(PYTHON) scripts/run.py

.PHONY: build-relocated runtime-check runtime-golden help split check-assets build verify verify-all test check-private-data lint format format-check
help:
	@$(RUN) build.help
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

include mk/authoring.mk

.PHONY: clean
clean:
	$(RUN) validation.clean

.PHONY: semantic-symbols-check
semantic-symbols-check:
	$(RUN) validation.semantics --compiled

.PHONY: release-tag-audit
release-tag-audit:
	$(RUN) validation.release_audit --clean --ready --post-tag --line $(LINE)

LINE ?= 1.0
