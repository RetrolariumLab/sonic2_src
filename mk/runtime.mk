.PHONY: build-relocated runtime-check runtime-golden
build-relocated:
	$(RUN) build.relocate $(if $(REV),--revision $(REV),--all)
runtime-check:
	$(RUN) runtime.movies check $(if $(REV),--revision $(REV))
runtime-golden:
	$(RUN) runtime.movies golden $(if $(REV),--revision $(REV))
