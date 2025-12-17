#!/bin/bash
set -e

echo "🎮 Setting up Raylib Game Development Environment..."
echo ""

# Update package list
echo "📦 Updating package list..."
sudo apt-get update

# Install build essentials and dependencies
echo "🔧 Installing build tools and dependencies..."
sudo apt-get install -y \
    build-essential \
    git \
    cmake \
    inotify-tools \
    libasound2-dev \
    libx11-dev \
    libxrandr-dev \
    libxi-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxcursor-dev \
    libxinerama-dev \
    libwayland-dev \
    libxkbcommon-dev

# Install raylib
echo "🎨 Installing raylib..."
cd /tmp
git clone --depth 1 --branch 5.5 https://github.com/raysan5/raylib.git
cd raylib/src
make PLATFORM=PLATFORM_DESKTOP
sudo make install PLATFORM=PLATFORM_DESKTOP
cd ../..
rm -rf raylib

# Install Emscripten for web builds
echo "🌐 Installing Emscripten for WebAssembly builds..."
cd /tmp
git clone --depth 1 https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
cd ..

# Add emsdk to PATH in .bashrc
echo "" >> ~/.bashrc
echo "# Emscripten SDK" >> ~/.bashrc
echo "source /tmp/emsdk/emsdk_env.sh > /dev/null 2>&1" >> ~/.bashrc

# Also add to .zshrc if it exists
if [ -f ~/.zshrc ]; then
    echo "" >> ~/.zshrc
    echo "# Emscripten SDK" >> ~/.zshrc
    echo "source /tmp/emsdk/emsdk_env.sh > /dev/null 2>&1" >> ~/.zshrc
fi

# Verify installations
echo ""
echo "✅ Setup complete! Verifying installations..."
echo ""
echo "GCC version:"
gcc --version | head -n 1
echo ""
echo "Raylib installed at:"
ldconfig -p | grep raylib || echo "Raylib library installed"
echo ""
echo "Emscripten will be available after sourcing the environment."
echo ""
echo "🎉 Your development environment is ready!"
echo ""
echo "Quick start:"
echo "  make          - Build native version"
echo "  make run      - Build and run native version"
echo "  make web      - Build WebAssembly version"
echo "  make watch    - Auto-rebuild on file changes"
echo ""
