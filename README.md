# Raylib Game Template

A minimal template for creating games with [raylib](https://www.raylib.com/) that supports both native desktop and web (WebAssembly) builds.

## ☁️ Quick Start with GitHub Codespaces

**No local setup required!** Open this project in GitHub Codespaces for instant development:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new)

All dependencies (raylib, Emscripten, build tools) are automatically installed. See [`.devcontainer/README.md`](.devcontainer/README.md) for details.

## Features

- 🎮 Cross-platform game development with raylib
- 🌐 Web support via Emscripten/WebAssembly
- 🛠️ Simple Makefile build system
- 📦 Automatic raylib dependency management for web builds
- 🎨 Clean HTML5 shell for web deployment

## Prerequisites

### For Native Builds (macOS/Linux)

- GCC or Clang compiler
- raylib library installed
  - **macOS**: `brew install raylib`
  - **Linux**: `sudo apt-get install libraylib-dev` (Ubuntu/Debian)

### For Web Builds

- [Emscripten SDK](https://emscripten.org/docs/getting_started/downloads.html) installed and activated

## Getting Started

### 1. Clone this template

```bash
git clone https://github.com/yourusername/raylib-game-template.git
cd raylib-game-template
```

### 2. Build and run natively

```bash
make
make run
```

### 3. Build for web

```bash
make web
make serve
```

Then open http://localhost:8000/index.html in your browser.

### 4. Development with auto-rebuild (watch mode)

```bash
# Watch and auto-rebuild native version
# Runs immediately, then watches for changes
make watch

# Watch and auto-rebuild web version (includes web server)
make watch-web
```

**How watch mode works:**
- Runs your game immediately
- Monitors your source files for changes
- On save: kills the old process, rebuilds, and runs the new version
- Instant feedback on your changes!

**Pro Tip**: Install `fswatch` for instant file change detection:
```bash
brew install fswatch  # macOS
sudo apt-get install inotify-tools  # Linux
```

Without `fswatch`, watch mode uses polling (checks every 1-2 seconds).

## Project Structure

```
.
├── main.c              # Your game code
├── Makefile           # Build configuration
├── shell.html         # HTML shell for web builds
├── resources/         # Game assets (fonts, images, sounds, etc.)
├── .gitignore        # Git ignore rules
└── README.md         # This file
```

## Development

### Main Game File

Edit `main.c` to create your game. The template provides a basic raylib game loop structure.

### Adding Resources

Place your game assets (fonts, images, sounds) in the `resources/` directory. These will be automatically embedded in web builds.

### Customization

- **Game name**: Change the `NAME` variable in the `Makefile`
- **Window size**: Modify `SCREEN_WIDTH` and `SCREEN_HEIGHT` in `main.c`
- **Web styling**: Edit `shell.html` to customize the appearance

## Makefile Targets

| Command | Description |
|---------|-------------|
| `make` or `make all` | Build native executable |
| `make run` | Build and run natively |
| `make web` | Build for web (creates HTML/JS/WASM files) |
| `make serve` | Start a local web server and open the game in browser |
| `make watch` | 👀 Auto-rebuild and run on file changes (native) |
| `make watch-web` | 👀 Auto-rebuild web version on changes + live server |
| `make clean` | Remove all build artifacts |

## Web Deployment

After running `make web`, you'll have a `dist/` directory with these files ready for deployment:

- `index.html` - Main HTML file
- `game.js` - JavaScript glue code
- `game.wasm` - WebAssembly binary
- `game.data` - Packed resources

Upload the contents of the `dist/` directory to any static web hosting service (GitHub Pages, Netlify, Vercel, etc.).

### GitHub Pages

This template includes automatic deployment to GitHub Pages:
1. **Enable GitHub Pages**: Go to your repository Settings → Pages → Source, and select "Deploy from a branch" with `gh-pages` branch and `/ (root)` folder
2. Push to the `main` branch to trigger the build and deployment
3. Your game will be available at `https://<username>.github.io/<repository-name>/`
4. The workflow builds the web version and deploys it automatically

**Note**: After the first deployment, it may take a few minutes for your site to become available.

## Tips

- The web build automatically downloads and compiles raylib for WebAssembly on first build
- Resources are embedded in the `.data` file for web builds
- Use `PLATFORM_WEB` preprocessor directive for web-specific code
- The template uses ASYNCIFY for proper game loop support on web

## License

This template is provided as-is for you to use in your projects. Feel free to modify and distribute as needed.

## Resources

- [raylib Documentation](https://www.raylib.com/)
- [raylib Examples](https://www.raylib.com/examples.html)
- [Emscripten Documentation](https://emscripten.org/)

## Contributing

Feel free to submit issues and pull requests to improve this template!
