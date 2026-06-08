LOVE ?= $(shell if command -v love >/dev/null 2>&1; then command -v love; elif [ -x /Applications/love.app/Contents/MacOS/love ]; then printf %s /Applications/love.app/Contents/MacOS/love; else printf %s love; fi)
NAME ?= slimebound-siege
BUILD_DIR := build
LOVE_FILE := $(BUILD_DIR)/$(NAME).love

.PHONY: run check package clean

run:
	$(LOVE) .

check:
	@find . -name '*.lua' -not -path './build/*' -print0 | xargs -0 -n1 luac -p
	@LUA=$$(command -v luajit || command -v lua); \
	if [ -n "$$LUA" ]; then \
		for s in resolver_spec abilities_spec; do $$LUA tests/$$s.lua || exit 1; done; \
	else echo "no lua/luajit on PATH; specs not run"; fi

package: clean
	@mkdir -p $(BUILD_DIR)
	@zip -9 -r $(LOVE_FILE) . \
		-x '*.git*' \
		-x 'build/*' \
		-x '.DS_Store'
	@echo "Created $(LOVE_FILE)"

clean:
	@rm -rf $(BUILD_DIR)
