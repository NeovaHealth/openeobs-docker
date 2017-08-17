# nh_github

Helpful script for working with NH repos on Github

## GITHUB API

Create a Personal access token on Github

* Set your token as an environment var
    * export GH_TOKEN=your_token_here
* Invoke script passing token
    * GH_TOKEN=your_token_here ./pull_archives.sh

## Parameters

* fetch
    * will fetch .zip of the repos in GH_REPO
* extract
    * will fetch .zip & extract each of the repos in GH_REPO
* makeaddons
    * will create odoo-addons.zip after a fetch & extract of each repo in GH_REPO
* clean
    * will remove OUTDIR and all .zip files