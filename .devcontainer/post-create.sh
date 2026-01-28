#!/bin/bash
set -e

echo "Fixing Yarn GPG signatures..."
# 1. Download the new key and save it to the modern keyring location
curl -sS https://dl.yarnpkg.com | gpg --dearmor | sudo tee /usr/share/keyrings/yarn-archive-keyring.gpg >/dev/null

# 2. Update the yarn.list to use the specific 'signed-by' path
echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# 3. Clean up the old/expired key if it exists in the legacy keyring to prevent noise
sudo apt-key del 88B63E1E || true

# 4. Update apt-get now that the signatures are valid
sudo apt-get update

echo "Yarn key fixed. Proceeding with remaining setup..."

# --- YOUR EXISTING POST-CREATE LOGIC BELOW ---

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

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
