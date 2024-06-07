#!/bin/sh

set -e

SOURCE_REPO=$1
DESTINATION_REPO=$2

if ! echo $SOURCE_REPO | grep -Eq ':|@|\.git\/?$'; then
  if [[ -n "$SSH_PRIVATE_KEY" || -n "$SOURCE_SSH_PRIVATE_KEY" ]]; then
    SOURCE_REPO="git@github.com:${SOURCE_REPO}.git"
    GIT_SSH_COMMAND="ssh -v"
  else
    SOURCE_REPO="https://github.com/${SOURCE_REPO}.git"
  fi
fi

if ! echo $DESTINATION_REPO | grep -Eq ':|@|\.git\/?$'; then
  if [[ -n "$SSH_PRIVATE_KEY" || -n "$DESTINATION_SSH_PRIVATE_KEY" ]]; then
    DESTINATION_REPO="git@github.com:${DESTINATION_REPO}.git"
    GIT_SSH_COMMAND="ssh -v"
  else
    DESTINATION_REPO="https://github.com/${DESTINATION_REPO}.git"
  fi
fi

echo "SOURCE=$SOURCE_REPO"
echo "DESTINATION=$DESTINATION_REPO"

echo ">>> Cloning source..."
if [[ -n "$SOURCE_SSH_PRIVATE_KEY" ]]; then
  # Clone using source ssh key if provided
  git clone -c core.sshCommand="/usr/bin/ssh -i ~/.ssh/src_rsa" "$SOURCE_REPO" /root/source --origin source --mirror && cd /root/source
else
  git clone "$SOURCE_REPO" /root/source --origin source --mirror && cd /root/source
fi

# Exclude pulls
echo ">>> Exclude pulls from fetch..."
git config --local --unset-all remote.source.fetch
git config --local --add remote.source.fetch '+refs/heads/*:refs/heads/*'
git config --local --add remote.source.fetch '+refs/tags/*:refs/tags/*'
git config --local --add remote.source.fetch '+refs/changes/*:refs/changes/*'


# Add destination remote
git remote add --mirror=push destination "$DESTINATION_REPO"

if [[ -n "$DESTINATION_SSH_PRIVATE_KEY" ]]; then
  # Push using destination ssh key if provided
  git config --local core.sshCommand "/usr/bin/ssh -i ~/.ssh/dst_rsa"
fi

echo ">>> Exclude pulls from push..."
git config --local --unset-all remote.destination.push
git config --local --add remote.destination.push '+refs/heads/*:refs/heads/*'
git config --local --add remote.destination.push '+refs/tags/*:refs/tags/*'
git config --local --add remote.destination.push '+refs/changes/*:refs/changes/*'

echo ">>> Pruning"
git fetch --prune source

echo ">>> Pushing git changes..."
git push --mirror destination

