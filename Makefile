# Project
NAME    := game
SRC     := main.c font_cache.c
CC      := gcc

# Detect OS
UNAME_S := $(shell uname -s)

# Choose MD5 command based on OS
ifeq ($(UNAME_S),Darwin)
    MD5 := md5
else
    MD5 := md5sum
endif

# Flags
CFLAGS  := -std=c11 -Wall -Wextra -O2

# macOS-specific settings
ifeq ($(UNAME_S),Darwin)
    CFLAGS  += $(shell pkg-config --cflags raylib 2>/dev/null || echo "-I/opt/homebrew/include -I/usr/local/include")
    LDFLAGS := $(shell pkg-config --libs raylib 2>/dev/null || echo "-L/opt/homebrew/lib -L/usr/local/lib -lraylib")
    LDFLAGS += -framework CoreVideo -framework IOKit -framework Cocoa -framework GLUT -framework OpenGL
else
    # Linux/other settings
    CFLAGS  += $(shell pkg-config --cflags raylib)
    LDFLAGS := $(shell pkg-config --libs raylib)
endif

# Targets
all: $(NAME)

$(NAME): $(SRC)
	$(CC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

clean:
	rm -f $(NAME) $(NAME).wasm $(NAME).js $(NAME).html $(NAME).data
	rm -rf raylib-web raylib-src dist

run: $(NAME)
	./$(NAME)

run-cage: $(NAME)
	cage ./$(NAME)

# WebAssembly target
RAYLIB_WEB := raylib-web
RAYLIB_WEB_INCLUDE := $(RAYLIB_WEB)/include
RAYLIB_WEB_LIB := $(RAYLIB_WEB)/lib/libraylib.a
DIST_DIR := dist

web: $(NAME).html
	@echo "WebAssembly build complete!"
	@mkdir -p $(DIST_DIR)
	@cp $(NAME).html $(DIST_DIR)/index.html
	@cp $(NAME).js $(DIST_DIR)/
	@cp $(NAME).wasm $(DIST_DIR)/
	@cp $(NAME).data $(DIST_DIR)/
	@echo "Files copied to $(DIST_DIR)/ directory"
	@echo "Run 'make serve' to start a local web server"

$(RAYLIB_WEB_LIB):
	@echo "Downloading raylib for web..."
	@mkdir -p $(RAYLIB_WEB)
	@if [ ! -d "raylib-src" ]; then \
		git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib.git raylib-src; \
	fi
	@echo "Building raylib for web..."
	@cd raylib-src/src && emmake make PLATFORM=PLATFORM_WEB -B
	@mkdir -p $(RAYLIB_WEB_INCLUDE) $(dir $(RAYLIB_WEB_LIB))
	@cp raylib-src/src/libraylib.a $(RAYLIB_WEB_LIB)
	@cp raylib-src/src/raylib.h $(RAYLIB_WEB_INCLUDE)/
	@cp raylib-src/src/raymath.h $(RAYLIB_WEB_INCLUDE)/
	@cp raylib-src/src/rlgl.h $(RAYLIB_WEB_INCLUDE)/
	@echo "raylib for web is ready!"

$(NAME).html: $(SRC) $(RAYLIB_WEB_LIB)
	emcc $(SRC) -o $(NAME).html \
		-std=c11 -Wall -Wextra -O2 \
		-s USE_GLFW=3 \
		-s ASYNCIFY \
		-s TOTAL_MEMORY=67108864 \
		-s FORCE_FILESYSTEM=1 \
		--preload-file resources \
		--shell-file shell.html \
		-DPLATFORM_WEB \
		-I$(RAYLIB_WEB_INCLUDE) \
		$(RAYLIB_WEB_LIB)

# Simple HTTP server for testing
serve:
	@if [ ! -d "$(DIST_DIR)" ]; then \
		echo "Error: $(DIST_DIR) directory not found. Run 'make web' first."; \
		exit 1; \
	fi
	@echo "Starting web server at http://localhost:8000"
	@echo "Opening http://localhost:8000/index.html in your browser"
	@echo "Press Ctrl+C to stop the server"
	@cd $(DIST_DIR) && (open http://localhost:8000/index.html || xdg-open http://localhost:8000/index.html || true) & python3 -m http.server 8000

# Watch for changes and rebuild
watch:
	@echo "👀 Watching for changes... (Press Ctrl+C to stop)"
	@echo "Building initial version..."
	@$(MAKE) $(NAME)
	@echo "Starting game..."
	@rm -f /tmp/game_game.pid /tmp/game_watch_fifo; \
	mkfifo /tmp/game_watch_fifo 2>/dev/null || true; \
	./$(NAME) & \
	GAME_PID=$$!; \
	echo $$GAME_PID > /tmp/game_game.pid; \
	echo "Game started (PID: $$GAME_PID)"; \
	echo "Now watching for changes..."; \
	echo ""; \
	cleanup_watch() { \
		if [ -f /tmp/game_game.pid ]; then \
			OLD_PID=$$(cat /tmp/game_game.pid 2>/dev/null); \
			[ -n "$$OLD_PID" ] && kill -9 $$OLD_PID 2>/dev/null; \
		fi; \
		pkill -9 fswatch 2>/dev/null; \
		pkill -P $$$$ 2>/dev/null; \
		rm -f /tmp/game_game.pid /tmp/game_watch_fifo; \
		echo ""; \
		echo "Watch stopped, game closed"; \
	}; \
	trap cleanup_watch EXIT INT TERM; \
	if command -v fswatch >/dev/null 2>&1; then \
		echo "Using fswatch for file monitoring"; \
		LAST_BUILD=0; \
		fswatch -o $(SRC) resources/ shell.html 2>/dev/null | while read -r line; do \
			NOW=$$(date +%s); \
			if [ $$((NOW - LAST_BUILD)) -gt 1 ]; then \
				LAST_BUILD=$$NOW; \
				echo "🔨 Change detected, rebuilding..."; \
				if [ -f /tmp/game_game.pid ]; then \
					OLD_PID=$$(cat /tmp/game_game.pid 2>/dev/null); \
				else \
					OLD_PID=""; \
				fi; \
				if [ -n "$$OLD_PID" ]; then \
					if ps -p $$OLD_PID > /dev/null 2>&1; then \
						echo "Killing old game (PID: $$OLD_PID)"; \
						kill -TERM $$OLD_PID 2>/dev/null || true; \
						sleep 0.3; \
						if ps -p $$OLD_PID > /dev/null 2>&1; then \
							kill -KILL $$OLD_PID 2>/dev/null || true; \
							sleep 0.2; \
						fi; \
					fi; \
				fi; \
				if $(MAKE) $(NAME); then \
					./$(NAME) & \
					NEW_PID=$$!; \
					echo $$NEW_PID > /tmp/game_game.pid; \
					echo "✅ Game restarted (PID: $$NEW_PID)"; \
				else \
					echo "❌ Build failed"; \
				fi; \
				echo ""; \
			fi; \
		done; \
	elif command -v inotifywait >/dev/null 2>&1; then \
		echo "Using inotifywait for file monitoring"; \
		LAST_BUILD=0; \
		inotifywait -qrme modify,create,delete $(SRC) resources/ shell.html 2>/dev/null | while read -r; do \
			NOW=$$(date +%s); \
			if [ $$((NOW - LAST_BUILD)) -gt 1 ]; then \
				LAST_BUILD=$$NOW; \
				echo "🔨 Change detected, rebuilding..."; \
				if [ -f /tmp/game_game.pid ]; then \
					OLD_PID=$$(cat /tmp/game_game.pid 2>/dev/null); \
				else \
					OLD_PID=""; \
				fi; \
				if [ -n "$$OLD_PID" ]; then \
					if ps -p $$OLD_PID > /dev/null 2>&1; then \
						echo "Killing old game (PID: $$OLD_PID)"; \
						kill -TERM $$OLD_PID 2>/dev/null || true; \
						sleep 0.3; \
						if ps -p $$OLD_PID > /dev/null 2>&1; then \
							kill -KILL $$OLD_PID 2>/dev/null || true; \
							sleep 0.2; \
						fi; \
					fi; \
				fi; \
				if $(MAKE) $(NAME); then \
					./$(NAME) & \
					NEW_PID=$$!; \
					echo $$NEW_PID > /tmp/game_game.pid; \
					echo "✅ Game restarted (PID: $$NEW_PID)"; \
				else \
					echo "❌ Build failed"; \
				fi; \
				echo ""; \
			fi; \
		done; \
	else \
		echo "Using polling (install fswatch for better performance: brew install fswatch)"; \
		LAST_HASH=$$(find $(SRC) resources/ shell.html -type f -exec $(MD5) {} \; 2>/dev/null | $(MD5) | cut -d' ' -f1); \
		while true; do \
			sleep 5; \
			CURRENT_HASH=$$(find $(SRC) resources/ shell.html -type f -exec $(MD5) {} \; 2>/dev/null | $(MD5) | cut -d' ' -f1); \
			if [ "$$CURRENT_HASH" != "$$LAST_HASH" ]; then \
				echo "🔨 Change detected, rebuilding..."; \
				if [ -f /tmp/game_game.pid ]; then \
					OLD_PID=$$(cat /tmp/game_game.pid 2>/dev/null); \
				else \
					OLD_PID=""; \
				fi; \
				if [ -n "$$OLD_PID" ]; then \
					if ps -p $$OLD_PID > /dev/null 2>&1; then \
						echo "Killing old game (PID: $$OLD_PID)"; \
						kill -TERM $$OLD_PID 2>/dev/null || true; \
						sleep 1.0; \
						if ps -p $$OLD_PID > /dev/null 2>&1; then \
							kill -KILL $$OLD_PID 2>/dev/null || true; \
							sleep 1.0; \
						fi; \
					fi; \
				fi; \
				if $(MAKE) $(NAME); then \
					./$(NAME) & \
					NEW_PID=$$!; \
					echo $$NEW_PID > /tmp/game_game.pid; \
					echo "✅ Game restarted (PID: $$NEW_PID)"; \
				else \
					echo "❌ Build failed"; \
				fi; \
				LAST_HASH=$$CURRENT_HASH; \
				echo ""; \
			fi; \
		done; \
	fi

# Watch for changes and rebuild web version
watch-web:
	@echo "👀 Watching for web changes... (Press Ctrl+C to stop)"
	@echo "Will rebuild web version on file changes"
	@echo "Starting web server at http://localhost:8000"
	@echo "Open http://localhost:8000/index.html in your browser"
	@echo ""
	@# Start the web server in the background
	@mkdir -p $(DIST_DIR); \
	(cd $(DIST_DIR) && python3 -m http.server 8000 > /dev/null 2>&1) & \
	SERVER_PID=$$!; \
	echo "Server started (PID: $$SERVER_PID)"; \
	echo ""; \
	trap "kill $$SERVER_PID 2>/dev/null; echo 'Server stopped'" EXIT; \
	if command -v fswatch >/dev/null 2>&1; then \
		echo "Using fswatch for file monitoring"; \
		LAST_BUILD=0; \
		fswatch -o $(SRC) resources/ shell.html 2>/dev/null | while read num; do \
			NOW=$$(date +%s); \
			if [ $$((NOW - LAST_BUILD)) -gt 1 ]; then \
				LAST_BUILD=$$NOW; \
				echo ""; \
				echo "🔨 Change detected, rebuilding web..."; \
				$(MAKE) web && echo "✅ Rebuild complete! Refresh your browser."; \
			fi; \
	elif command -v inotifywait >/dev/null 2>&1; then \
		echo "Using inotifywait for file monitoring"; \
		LAST_BUILD=0; \
		inotifywait -qrme modify,create,delete $(SRC) resources/ shell.html 2>/dev/null | while read -r; do \
			NOW=$$(date +%s); \
			if [ $$((NOW - LAST_BUILD)) -gt 1 ]; then \
				LAST_BUILD=$$NOW; \
				echo ""; \
				echo "🔨 Change detected, rebuilding web..."; \
				$(MAKE) web && echo "✅ Rebuild complete! Refresh your browser."; \
			fi; \
		done; \
	else \
		echo "Using polling (install fswatch for better performance: brew install fswatch)"; \
		LAST_HASH=$$(find $(SRC) resources/ shell.html -type f -exec $(MD5) {} \; 2>/dev/null | $(MD5) | cut -d' ' -f1); \
		while true; do \
			sleep 2; \
			CURRENT_HASH=$$(find $(SRC) resources/ shell.html -type f -exec $(MD5) {} \; 2>/dev/null | $(MD5) | cut -d' ' -f1); \
			if [ "$$CURRENT_HASH" != "$$LAST_HASH" ]; then \
				echo ""; \
				echo "🔨 Change detected, rebuilding web..."; \
				$(MAKE) web && echo "✅ Rebuild complete! Refresh your browser."; \
				LAST_HASH=$$CURRENT_HASH; \
			fi; \
		done; \
	fi

.PHONY: all clean run run-cage web serve watch watch-web build

build: $(NAME)
