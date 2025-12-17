# GitHub Codespaces Setup

This project is configured to work seamlessly in GitHub Codespaces with all dependencies pre-installed.

## 🚀 Quick Start in Codespaces

1. **Open in Codespaces**
   - Click the green "Code" button on GitHub
   - Select "Codespaces" tab
   - Click "Create codespace on main"

2. **Wait for Setup**
   - The devcontainer will automatically:
     - Install build tools (gcc, make, cmake)
     - Install raylib library
     - Install Emscripten for WebAssembly builds
     - Configure VS Code with C/C++ extensions
   - This takes ~5-10 minutes on first setup

3. **Start Developing**
   ```bash
   make          # Build native version
   make web      # Build WebAssembly version
   make watch    # Auto-rebuild on changes
   ```

## 📦 What Gets Installed

### Build Tools
- GCC (C11 compiler)
- Make
- CMake
- Git

### Raylib (5.5)
- Installed system-wide
- Ready for native Linux builds
- Headers available in `/usr/local/include`

### Emscripten (Latest)
- For WebAssembly compilation
- Automatically sourced in shell
- Available via `emcc` command

### VS Code Extensions
- C/C++ Tools
- C/C++ Extension Pack
- Makefile Tools

## 🌐 Testing Web Builds

The web server port (8000) is automatically forwarded. After building:

```bash
make serve
```

Then click the "Ports" tab in VS Code and open the forwarded port 8000.

## 🔧 Manual Setup

If you need to reinstall dependencies:

```bash
bash .devcontainer/setup.sh
```

## 🐛 Troubleshooting

### Emscripten not found
```bash
source /tmp/emsdk/emsdk_env.sh
```

### Raylib not found
```bash
sudo ldconfig
pkg-config --libs raylib
```

### Rebuild everything
```bash
make clean
make
```

## 📝 Notes

- **Persistence**: The devcontainer setup persists across Codespace sessions
- **Resources**: Codespaces provides 2-4 cores and 8GB RAM by default
- **Storage**: ~32GB available for builds and assets
- **Auto-stop**: Codespaces auto-stop after 30 minutes of inactivity

## 🆚 Local vs Codespaces

| Feature | Local | Codespaces |
|---------|-------|------------|
| Setup Time | Manual | Automatic |
| Raylib | Homebrew/pkg | Pre-installed |
| Emscripten | Manual | Pre-configured |
| Platform | macOS/Linux/Windows | Linux (Ubuntu) |
| Watch Mode | fswatch (macOS) | inotifywait (Linux) |

## 🔗 Resources

- [Raylib Documentation](https://www.raylib.com/)
- [GitHub Codespaces Docs](https://docs.github.com/en/codespaces)
- [Dev Container Spec](https://containers.dev/)
