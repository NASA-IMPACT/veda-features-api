# VEDA Features API

Hosting and serving collections of vector data features for VEDA

---

## Implementation

* Storage: PostGIS
* WFS3 API with query support: [OGC API Features](https://ogcapi.ogc.org/features/) provided by [TiPG](https://github.com/developmentseed/tipg)
* Vector tiles API provided by [TiPG](https://github.com/developmentseed/tipg)

---

### Local Development in Docker

To locally run the site:

`docker-compose up`

---

### Development Setup

Folks working on this project can play with development locally 

--- 

### Continuous Deployment for `staging` and `production`

Unless you're manually deploying a `dev` environment all deploys happen through the CI/CD Github Actions. So grok those for answers

We use this action to create tags https://github.com/mathieudutour/github-tag-action

This uses [conventional commit methodology](https://www.conventionalcommits.org/en/v1.0.0/) to create tags using the logic detailed [here](https://github.com/mathieudutour/github-tag-action#bumping)

---

### Manual 'dev' Deployment

Because AWS Elastic IP limits we have been running `dev` deploys in `us-west-1`. Note that `/terraform/veda-wfs3/vars/dev.tf`
is bound to that region

* install `tfenv` to manage multiple versions: [https://github.com/tfutils/tfenv](https://github.com/tfutils/tfenv)
* our `init.tf` file has a `required_version = "1.3.9"` so install that:

```bash
$ tfenv list
  1.1.5
  1.1.4
  
$ tfenv install 1.3.9
$ tfenv use 1.3.9
```
* make sure you setup an `AWS_PROFILE` in your `~/.aws/confg|credentials` files for `us-west-1`
* then you can run `AWS_PROFILE=uah1 terraform init`
* make sure you `cp envtf.template .envtf.sh` and change values in there for secrets needed
* then `source .envtf.sh`
* then `cd /terraform/veda-wfs3`
* then `AWS_PROFILE=uah1 terraform <plan|apply> -var-file=./vars/dev.tf`

---

### Observability and Alarms

[See Obervability and Monitoring](./docs/OBSERVABILITY.md)

---

### License
This project is licensed under **Apache 2**, see the [LICENSE](LICENSE) file for more details.
