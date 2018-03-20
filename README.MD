# LiveObs Docker
This docker image builds on top of the [LiveObs Odoo](https://github.com/bjss/liveobs-odoo-docker)
image and adds the LiveObs addons from [Neovahealth/nhclinical](https://github.com/NeovaHealth/nhclinical),
[Neovahealth/openeobs](https://github.com/NeovaHealth/openeobs) and [BJSS/BJSS_LiveObs_client_modules](https://github.com/BJSS/BJSS_LiveObs_client_modules)

You can find more detailed information about the builds in the comments in `liveobs/docker/Makefile`.

The **helper scripts** repo was copied to a subdirectory of this repo as a 
quick fix so that it can easily be added to Docker's build context. We may 
decide to keep it in here and decommission the original helper scripts repo as 
it is not used anywhere else currently.