#!/bin/bash

# jq, bash-completion, tree, gettext, moreutilsのインストール
sudo yum -y install jq bash-completion tree gettext moreutils

# Docker Compose のインストール
COMPOSE_VERSION=$(curl -s "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v${COMPOSE_VERSION}/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# kubectl のコマンド補完
kubectl completion bash > kubectl_completion
sudo mv kubectl_completion /etc/bash_completion.d/kubectl

# eksctl のコマンド補完
eksctl completion bash > eksctl_completion
sudo mv eksctl_completion /etc/bash_completion.d/eksctl

# Docker のコマンド補完
sudo curl -L -o /etc/bash_completion.d/docker https://raw.githubusercontent.com/docker/cli/master/contrib/completion/bash/docker

# kubectl エイリアス設定
cat <<"EOT" >> ${HOME}/.bashrc
alias k="kubectl"
complete -o default -F __start_kubectl k
EOT

# kube-ps1 のインストールと設定
git clone https://github.com/jonmosco/kube-ps1.git ~/.kube-ps1
cat <<"EOT" >> ~/.bashrc
source ~/.kube-ps1/kube-ps1.sh
function get_cluster_short() {
  echo "$1" | cut -d . -f1
}
KUBE_PS1_CLUSTER_FUNCTION=get_cluster_short
KUBE_PS1_SUFFIX=') '
PS1='$(kube_ps1)'$PS1
EOT

# kubectx と kubens のインストールと設定
git clone https://github.com/ahmetb/kubectx.git ~/.kubectx
sudo ln -sf ~/.kubectx/completion/kubens.bash /etc/bash_completion.d/kubens
sudo ln -sf ~/.kubectx/completion/kubectx.bash /etc/bash_completion.d/kubectx
cat <<"EOT" >> ~/.bashrc
export PATH=~/.kubectx:$PATH
EOT

# stern のインストール
STERN_VERSION=$(curl -s "https://api.github.com/repos/stern/stern/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -L "https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/stern /usr/local/bin

# bashrc と bash_completion の読み込み
. ~/.bashrc
. /etc/profile.d/bash_completion.sh
. /etc/bash_completion.d/kubectl
. /etc/bash_completion.d/eksctl
. /etc/bash_completion.d/docker

echo "All tools and configurations have been installed and applied."
