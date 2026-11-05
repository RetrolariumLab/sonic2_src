.PHONY: build-relocated runtime-check runtime-golden
build-relocated:
	$(RUN) build.relocate $(if $(REV),--revision $(REV),--all)
runtime-check:
	$(RUN) runtime.movies check $(if $(REV),--revision $(REV))
runtime-golden:
	$(RUN) runtime.movies golden $(if $(REV),--revision $(REV))

.PHONY: runtime-extended-check runtime-extended-golden
runtime-extended-check:
	$(RUN) runtime.extended check
runtime-extended-golden:
	$(RUN) runtime.extended golden
