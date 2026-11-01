.PHONY: split check-assets build verify verify-all
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
