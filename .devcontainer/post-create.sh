#!/bin/bash
### -------------------
### Uncomment ll command in bashrc
### -------------------

sed -i -e "s/#alias ll='ls -l'/alias ll='ls -al'/g" ~/.bashrc
. $HOME/.bashrc

### -------------------
### Install pip and the uv package
### -------------------

pip install --upgrade pip
pip install uv

### -------------------
### Install gcloud CLI
### -------------------

# I am installing it here instead of via devcontainer feature
# because I can't install gke-gcloud-auth-plugin if gcloud is installed that way.
sudo apt-get update && sudo apt-get install -y apt-transport-https gnupg curl lsb-release
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
  echo "cloud SDK repo: $CLOUD_SDK_REPO" && \
  echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
  sudo curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  sudo apt-get update -y && sudo apt-get install google-cloud-sdk -y

sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin

### -------------------
### Install Helm
### -------------------
sudo apt-get install curl gpg apt-transport-https --yes
curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
