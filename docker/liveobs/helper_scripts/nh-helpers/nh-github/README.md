## Neova Health

Creates odoo-addons.zip from GitHub repositories

### GITHUB API

Create a Personal access token on Github

* Set your token as an environment var
    * export GH_TOKEN=your_token_here
* Invoke script passing token
    * GH_TOKEN=your_token_here ./pull_archives.sh

### Parameters

* -b *branchname*
    * will fetch .zip of *branchname* for the repos in GH_REPO
* -c
    * will remove NH_OUTDIR and all .zip files

### Variables

* GH_ORG=NeovaHealth
* GH_REPO='nhclinical openeobs patientflow'
* GH_FORMAT=zip
* NH_OUTDIR=odoo-addons