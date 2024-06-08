# SSH Step-by-Step Guide

## Summary

Git-Sync is a GitHub action that can be used to synchronize one repo with another using a GitHub action. Synchronize means that any commits made to the SOURCE REPO are automatically pushed to the DESTINATION REPO.

Note that the mechanism used for this SYNC only works as a ONE-DIRECTIONAL MIRROR synchronization (from SOURCE REPO to DESTINATION REPO). This means NO COMMITS must be made on the DESTINATION REPO.

**Definitions**

SOURCE REPO - A GitHub repository that contains code you want to push into another Git DESTINATION REPO. You will be making lots of commits to this repo, into as many branches as necessary. This repo will be protected using your normal authentication mechanisms plus a READ ONLY DEPLOYMENT KEY.

DESTINATION REPO - A Git repository (not necessarily GitHub) that you want to use as a MIRROR of your SOURCE REPO. No one, other than your SOURCE REPO GitHub Action should be making commits to this repository. The destination does not need to be on GitHub but must be accessible from the GitHub action containers (which generally will mean that it's public internet accessible). This repo will be protected using your normal authentication mechanisms plus a WRITE DEPLOYMENT KEY.

Always keep all keys SECRET!

## Setup Overview

By following the steps in this Step-by-Step:

1. You will add a GitHub action **workflow** file to your SOURCE REPO to synchronize to another repo (which we'll call "DESTINATION REPO").
2. You will create SSH keys for your source and DESTINATION REPOs.
3. You will configure secrets on the SOURCE REPO (to hold SSH keys that the GitHub action will use).
4. You will configure deployment keys for both repos (so you can read from the source, and write to the destination.)
5. You will enable GitHub actions on the SOURCE REPO and disable GitHub actions on the DESTINATION REPO.
6. You will confirm the sync is working with a test commit!

After this setup, any **FUTURE** commits to your SOURCE REPO will be also committed to your DESTINATION REPO.

## Theory of Operation

The synchronization is carried out by a GitHub action set to run on each and every **push** to a source GitHub repository.

GitHub actions are actually containers that are instantiated when certain events happen to your repo (a repo **push** in this case.) The GitHub action is started by the GitHub controller if the event criteria in the action YML file is met (in this case, the **push**.)

The git-sync action we discuss here starts up an Ubuntu container with git installed. It then clones a mirror of the SOURCE REPO and pushes it to the DESTINATION REPO. 

The full source code of this action is available at: https://github.com/dmejiar/git-sync.

## SOURCE REPO Preparation

1. For now, disable GitHub Actions (Settings > Actions > General) since we still have to set up the destination before any of this will work!
2. Add a folder to the repo called `.github/workflows`.
3. Inside the new folder, create a file sync.yml using the below as base. Be sure to change the values for `source_repo` and `destination_repo` in the below base. Everything else can be left intact.

    ```yml
    on:
      push:
        # Sync all branches
        branches:
          - '*'
        # Sync all tags, and generally limit tags to ONLY the branches being synced
        tags:
          - ‘*’

    jobs:
      git-sync:
        runs-on: ubuntu-latest
        steps:
          - name: git-sync
            uses: dmejiar/git-sync@v1
            with:
              source_repo: “git@github.com:Some_User_or_Org/some-source-repo.git”
              destination_repo: “git@github.com:Some_User_or_Org/some-dest-repo.git”
              source_ssh_private_key: ${{ secrets.SOURCE_SSH_PRIVATE_KEY }}
              destination_ssh_private_key: ${{ secrets.DESTINATION_SSH_PRIVATE_KEY }}
    ```
    > **Note:** We're using SSH URLs in the above source and destination URLs. Though this action could work with HTTPS URLs as well, the instructions here are tailored for SSH URLs. Using HTTPS URLs requires different instructions not included here.

4. Generate SSH KEYS that will be used to protect the SOURCE REPO, updating the values with **XXX** and **projectname** with values to suit. (These are for documentation purposes, so you can use any values.)

    ```bash
    ssh-keygen -t rsa -b 4096 -C "PXXX Project Name" -f ./pxxx-projectname-source -N ''
    ```
    > **Note:** These steps are for macOS/Linux. On Windows, you will need to install an application capable of generating SSH keys. Note, you MUST USE "RSA" keys at least 4096 bits. Other key types will not work with this action (or at least have not been tested.)

    This will create 2 files called “pxxx-projectname-source” the second with the extension .pub. The file with no extension is the private key and the .pub is the public key.

    Save these two keys in some private secure location in case you ever need to update this!

5. Generate SSH KEYS that will be used to protect the DESTINATION REPO, updating the values with **XXX** and **projectname** with values to suit. (These are for documentation purposes, so you can use any values.)

    ```bash
    ssh-keygen -t rsa -b 4096 -C "PXXX Project Name" -f ./pxxx-projectname-destination -N ''
    ```
    > **Note:** These steps are for macOS/Linux. On windows, you will need to install an application capable of generating SSH keys. Note, you MUST USE "RSA" keys at least 4096 bits. Other key types will not work with this action (or at least have not been tested.)

    This will create 2 files called “pxxx-projectname-destination” the second with the extension .pub. The file with no extension is the private key and the .pub is the public key.

    Save these two keys in some private secure location in case you ever need to update this!

6. Add the keys to the SOURCE REPO (replace **key_name** with the **pxxx-projectname** you used when you created the keys!)
    * Add the source public key (**key_name**-source.pub) to Repo Settings > Deploy keys. Ensure **READ ONLY** access (keys are read-only by default). This key will only allow the corresponding private key to  "read" from this SOURCE REPO.
    * Add the source private key (**key_name**-source) to Repo Settings > Secrets and Variables > Actions > Secrets > Repository secrets and call it **SOURCE_SSH_PRIVATE_KEY**.
    * Add the destination private key (**key_name**-destination) to Repo Settings > Secrets and Variables > Actions > Secrets > Repository secrets and call it **DESTINATION_SSH_PRIVATE_KEY**.

## DESTINATION REPO Preparation

1. Verify that GitHub Actions is disabled for this destination (Settings > Actions > General). We don't need GitHub actions on the destination side!
2. Add the deployment key to the DESTINATION REPO.
    * Add the public key (**key_name**-destination.pub) to Repo Settings > Deploy keys. Ensure **WRITE** access (keys are read-only by default, so you have to change this value). This key will allow the corresponding private key to "write" into this DESTINATION REPO (necessary for the action to be useful).

##  First time Synchronization + Verification

Once all the above steps are completed:

1. On the SOURCE REPO, enable GitHub Actions (Settings > Actions > General).
2. Make a simple change to the repo and commit to a BRANCH.
3. On the SOURCE REPO notice there is now an ACTIONS main tab. Click on ACTIONS, and you will see a history of the actions. Click on any action to see results or to debug further for actions that failed.
4. If your action is completed successfully, go to the DESTINATION REPO and you should see the latest version matching your latest change.



