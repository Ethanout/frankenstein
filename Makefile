.PHONY: build test clean

build:
	beet build

test:
	@echo "Add repository-wide tests under tests/"

clean:
	@echo "Clean project outputs from their owning subprojects"
