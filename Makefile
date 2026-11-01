.DEFAULT_GOAL := help
PYTHON ?= python
export PYTHONDONTWRITEBYTECODE := 1
REV ?=
ROM_DIR ?=
RUN = $(PYTHON) scripts/run.py

.PHONY: help
help:
	@$(RUN) build.help

include mk/build.mk
include mk/runtime.mk
include mk/validation.mk
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
