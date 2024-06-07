# Git Sync

A GitHub Action for updating a GitHub mirror repository.

## Features

- Updated GitHub mirror repository
- GitHub action can be triggered on a timer or on push (branches and tags)

## Quick Setup Step-by-Step

Please see the [SSH Step-by-Step Guide](README-SSH-Step-by-Step-Guide.md) for step-by-step instructions using SSH.

## Usage

> Always make a full backup of your repo (`git clone --mirror`) before using this action.

### GitHub Actions

```yml
# .github/workflows/git-sync.yml

on: push

jobs:
  git-sync:
    runs-on: ubuntu-latest
    steps:
      - name: git-sync
        uses: dmejiar/git-sync@v1
        with:
          source_repo: "git@github.com:source-org/source-repo.git"
          source_branch: "${{ github.event.ref }}"
          destination_repo: "git@github.com:destination-org/destination-repo.git"
          destination_branch: "${{ github.event.ref }}"
          source_ssh_private_key: ${{ secrets.SOURCE_SSH_PRIVATE_KEY }}
          destination_ssh_private_key: ${{ secrets.DESTINATION_SSH_PRIVATE_KEY }}

```

##### Using shorthand

You can use GitHub repo shorthand like `username/repository.git`.

##### Using ssh

> The `ssh_private_key`, or `source_ssh_private_key` and `destination_ssh_private_key` must be supplied if using ssh clone urls.

```yml
source_repo: "git@github.com:username/repository.git"
```
or
```yml
source_repo: "git@gitlab.com:username/repository.git"
```

##### Using https

> The `ssh_private_key`, `source_ssh_private_key` and `destination_ssh_private_key` can be omitted if using authenticated https urls.

```yml
source_repo: "https://username:personal_access_token@github.com/username/repository.git"
```

#### Set up deploy keys

> You only need to set up deploy keys if the repository is private and the ssh clone url is used.

- Either generate different SSH keys for both source and destination repositories or use the same one for both, leave the passphrase empty (note that GitHub deploy keys must be unique for each repository)

```sh
$ ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

- In GitHub, either:

  - Add the unique public keys (`key_name.pub`) to _Repo Settings > Deploy keys_ for each repository respectively and allow write access for the destination repository

  or

  - add the single public key (`key_name.pub`) to _Personal Settings > SSH keys_

- Add the private key(s) to _Repo > Settings > Secrets_ for the repository containing the action (`SSH_PRIVATE_KEY`, or `SOURCE_SSH_PRIVATE_KEY` and `DESTINATION_SSH_PRIVATE_KEY`)

### Docker

You can run this in Docker locally for testing and development.

```sh
$ docker run --rm -e "SSH_PRIVATE_KEY=$(cat ~/.ssh/id_rsa)" $(docker build -q .) \
  $SOURCE_REPO $DESTINATION_REPO
```

