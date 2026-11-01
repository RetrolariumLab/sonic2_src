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
