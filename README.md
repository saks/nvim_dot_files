### Setup steps
```sh
add-apt-repository ppa:neovim-ppa/unstable
apt update
apt install neovim python3-pip
pip3 install --upgrade neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.config/nvim
git clone https://github.com/saks/nvim_dot_files.git ~/.config/nvim/
nvim +PlugInstall +qall
```
