CORE_SOURCE ?=
CMAKE_GENERATOR ?=
export CORE_SOURCE CMAKE_GENERATOR

.PHONY: prepare-core roundtrip-formats check-content-zero-edit
prepare-core:
	$(RUN) build.core_tool $(if $(CORE_SOURCE),--source "$(CORE_SOURCE)") $(if $(CMAKE_GENERATOR),--generator "$(CMAKE_GENERATOR)")
roundtrip-formats:
	$(RUN) authoring.roundtrip formats
check-content-zero-edit:
	$(RUN) authoring.roundtrip zero-edit
