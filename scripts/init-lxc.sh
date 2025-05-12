#!/bin/bash

USERNAME="code"

echo nameserver 1.1.1.1 >/etc/resolv.conf

# Update system
apt-get update

# Install dependencies
apt-get install ca-certificates curl sudo zsh build-essential rsync -y

# Install Docker dependencies
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" |
  tee /etc/apt/sources.list.d/docker.list >/dev/null
apt-get update

# Install Docker
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose -y

apt-get upgrade -y
apt-get autoremove -y

# Add user to docker group
useradd -m $USERNAME
groupadd docker
usermod -aG docker $USERNAME
usermod -aG sudo $USERNAME

# Generate SSH key
su - $USERNAME <<EOF
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
EOF

chsh -s $(which zsh)

cat <<'EOF'
Done!
- change to user $USERNAME password:
  passwd $USERNAME
- switch to user $USERNAME:
  su - $USERNAME
- switch to zsh:
  sh -c "$(curl -fsSL https://install.ohmyz.sh)"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  zsh
EOF
