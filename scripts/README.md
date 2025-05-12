# Scripts

## init-lxc.sh

### On container

Run script on container

Reset the `code` user password

```shell
passwd code
```

### On local machine

Remove previous entry from `~/.ssh/known_hosts`

```shell
ssh-keygen -R 192.168.0.XXX
```

Add your public key to the lxc `authorized_keys`

```shell
ssh-copy-id code@192.168.0.XXX
```

Update your `~/.ssh/config`

```shell
code ~/.ssh/config
```

```shell
Host local-host
HostName 192.168.0.XXX
User code
```

```shell
# oh my zsh
sh -c "$(curl -fsSL https://install.ohmyz.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
source ~/.zshrc
```
