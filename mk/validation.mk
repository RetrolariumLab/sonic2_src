.PHONY: test lint format format-check check-private-data pointer-audit source-1-check release-check release-audit check-stop-words source-layout-check documentation-check scaffold-check source-2-check source-2-audit
test:
	$(PYTHON) -m unittest discover -s tests
lint:
	$(RUN) validation.lint_project lint
format:
	$(RUN) validation.lint_project format
format-check: lint
check-private-data:
	$(RUN) validation.private_data
pointer-audit:
	$(RUN) validation.pointers
source-1-check release-check:
	$(RUN) validation.source1
release-audit:
	$(RUN) validation.release_audit --clean
check-stop-words:
	$(PYTHON) -m retrolarium_core.stop_words history "$(CURDIR)" --all
source-layout-check:
	$(RUN) validation.structure
documentation-check:
	$(RUN) validation.documentation
scaffold-check:
	$(RUN) validation.scaffold
source-2-check source-2-audit:
	$(RUN) validation.source2
