### Install nvim
#### apt
```sh
add-apt-repository ppa:neovim-ppa/unstable
apt update
```

#### App image
```sh
INSTALLATION_PATH=/usr/local/bin/nvim
TEMP_INSTALLATION_PATH=/tmp/nvim
LATEST_RELEASE_URL=https://api.github.com/repos/neovim/neovim/releases/latest
URL=`curl --location $LATEST_RELEASE_URL | \
	grep browser_download_url | \
	grep nvim.appimage | \
	cut -d '"' -f 4`
curl --location $URL --output $TEMP_INSTALLATION_PATH
chmod +x $TEMP_INSTALLATION_PATH
sudo mv $TEMP_INSTALLATION_PATH $INSTALLATION_PATH
```

### Setup steps
```sh
apt install python3-pip
pip3 install --upgrade neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.config/nvim
git clone https://github.com/saks/nvim_dot_files.git ~/.config/nvim/
nvim +PlugInstall +qall
```
