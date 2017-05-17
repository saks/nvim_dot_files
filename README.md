### Setup steps
```sh
apt install nvim
pip3 install --upgrade neovim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir -p ~/.config/nvim
git clone https://github.com/saks/nvim_dot_files.git ~/.config/nvim/
nvim +PlugInstall +qall
```
