#
# Setup script for neovim configuration.
#

# TODO: add installation for macOS

set -e

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
RESOURCE_DIR="$REPO_DIR/resources"

# Neovim
install_neovim_linux() {
  sudo add-apt-repository -y ppa:neovim-ppa/unstable
  sudo apt-get install -y neovim
}

install_neovim_darwin() {
  # TODO: ensure brew exists
  brew install neovim
}

install_neovim() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_neovim_linux
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_neovim_darwin
  else
    exit 1
  fi
}

# Rust Analyzer
install_rust_analyzer_linux() {
  curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
  chmod +x ~/.local/bin/rust-analyzer
}

install_rust_analyzer_darwin() {
  brew install rust-analyzer
}

install_rust_analyzer() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_rust_analyzer_linux
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_rust_analyzer_darwin
  else
    exit 1
  fi
}

copy_config_files() {
  mkdir -p "$HOME/.config/nvim"
  cp -R "$RESOURCE_DIR/nvim" "$HOME/.config/"
}

# Update lists of packages
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  sudo apt-get update
fi

# Install dependencies
sudo apt-get install -y \
  curl \
  fzf \
  gcc \
  gem \
  nodejs \
  npm \
  python3 \
  python3-pip \
  ripgrep \
  ruby \
  ruby-dev \
  xdg-utils \
  xsel

echo 'source /usr/share/doc/fzf/examples/key-bindings.bash' >> "$HOME/.bashrc"
echo 'source /usr/share/doc/fzf/examples/completion.bash' >>  "$HOME/.bashrc"

sudo npm install -g yarn

curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

# install c/c++ language server
yarn global add ccls

# install bash language server
yarn global add bash-language-server

# install python language server
pip3 install 'python-lsp-server[all]'

# install markdown previews
yarn global add instant-markdown-d

install_rust_analyzer

# Install neovim
install_neovim

yarn global add neovim
pip3 install neovim
sudo gem install neovim

copy_config_files
