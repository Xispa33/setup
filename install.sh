#!/bin/bash

if [ ! -z "${DEBUG}" ];
then
  set -eux
fi

TMP=/tmp

vscode_install() {
  sudo snap install code --classic
}

git_install() {
  sudo apt install git-all -y
}

add_docker_apt_repo() {
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl -y
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
}

docker_install() {
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
  add_docker_apt_repo
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  # Configure Docker to start on boot
  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service

  # Run docker as non-root
  sudo groupadd docker
  sudo usermod -aG docker "${USER}"
  newgrp docker
}

zsh_install() {
  sudo apt install zsh -y
}

omzsh_install() {
  rm -rf "${HOME}/.oh-my-zsh" "${HOME}/.bash_completion.d"
  zsh_install
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # Auto completion and highlighting plugins
  ZSH_CUSTOM=${HOME}/.oh-my-zsh
  git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  # sed -i 's#ZSH_THEME=\"robbyrussell\"#ZSH_THEME=\"powerlevel10k\/powerlevel10k\"#g' ${HOME}/.zshrc
  chsh -s $(which zsh)

  cp .aliases .p10k.zsh .zshrc .bashrc ${HOME}
  # Autocompletion for aliases
  mkdir ~/.bash_completion.d
  curl https://raw.githubusercontent.com/cykerway/complete-alias/master/complete_alias > ~/.bash_completion.d/complete_alias
}

powerlevel10k_font_install() {
  # Each of these files need to be opened separetely to click on Install
  # Then, Preferences > Profile > Custom font > MesloGS NF
  curl --output ${TMP}/MesloLGS%20NF%20Regular.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
  curl --output ${TMP}/MesloLGS%20NF%20Bold.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
  curl --output ${TMP}/MesloLGS%20NF%20Italic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
  curl --output ${TMP}/MesloLGS%20NF%20Bold%20Italic.ttf https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
}

extra_packages_install() {
  sudo apt-get install -y taskwarrior
}

python_related_install() {
  sudo apt-get install -y python3-pip
}

gdb_dashboard_install() {
  cd "${HOME}"
  rm -rf .gdbinit*
  wget -P ~ https://github.com/cyrus-and/gdb-dashboard/raw/master/.gdbinit
  sudo apt-get install -y python3-pygments
}

base_install() {
 sudo apt-get install curl sudo wget -y
}

base_install
vscode_install
git_install
docker_install
omzsh_install
powerlevel10k_font_install
extra_packages_install
python_related_install
gdb_dashboard_install
