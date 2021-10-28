.PHONY: release
release:
	build/simple-release.sh

.PHONY: clean-builds
clean:
	rm -r bin/
