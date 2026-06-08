LOVE ?= $(shell if command -v love >/dev/null 2>&1; then command -v love; elif [ -x /Applications/love.app/Contents/MacOS/love ]; then printf %s /Applications/love.app/Contents/MacOS/love; else printf %s love; fi)
NAME ?= slimebound-siege
BUILD_DIR := build
LOVE_FILE := $(BUILD_DIR)/$(NAME).love

.PHONY: run check package clean

run:
	$(LOVE) .

check:
	@find . -name '*.lua' -not -path './build/*' -print0 | xargs -0 -n1 luac -p
	@if command -v luajit >/dev/null 2>&1; then luajit tests/resolver_spec.lua; \
	elif command -v lua >/dev/null 2>&1; then lua tests/resolver_spec.lua; \
	else echo "no lua/luajit on PATH; resolver spec not run"; fi

package: clean
	@mkdir -p $(BUILD_DIR)
	@zip -9 -r $(LOVE_FILE) . \
		-x '*.git*' \
		-x 'build/*' \
		-x '.DS_Store'
	@echo "Created $(LOVE_FILE)"

clean:
	@rm -rf $(BUILD_DIR)
