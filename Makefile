.PHONY: all generate open clean

# Generate the Xcode project from project.yml (installs XcodeGen if needed).
all: generate

generate:
	@./Scripts/bootstrap.sh

open: generate
	@open Daybreak.xcodeproj

clean:
	@rm -rf Daybreak.xcodeproj
