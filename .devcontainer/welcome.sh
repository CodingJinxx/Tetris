#!/bin/bash

cat << "EOF"

╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   🎮  Welcome to Raylib Game Development!                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

Your development environment is ready with:
  ✅ Raylib 5.5 (installed system-wide)
  ✅ Emscripten (for WebAssembly builds)
  ✅ Build tools (gcc, make, cmake)
  ✅ inotify-tools (for watch mode)

Quick Start Commands:
  📦 make              Build native game
  🏃 make run          Build and run game
  🌐 make web          Build for web (WASM)
  🔄 make watch        Auto-rebuild on changes
  🧹 make clean        Clean build artifacts

VS Code Tasks:
  Press Ctrl+Shift+B to see available build tasks
  Use the Command Palette (Ctrl+Shift+P) for more options

Documentation:
  📖 README.md                    Main documentation
  📖 .devcontainer/README.md      Codespaces guide
  📖 WATCH_MODE.md                Watch mode details

Happy coding! 🚀

EOF
