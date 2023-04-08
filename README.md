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

### Continuous Deployment for `staging` and `production`

Unless you're manually deploying a `dev` environment all deploys happen through the CI/CD Github Actions. So please
grok the `/.github/workflows/deploy.yaml`

We use a third-party action to create tags https://github.com/mathieudutour/github-tag-action

This uses [conventional commit methodology](https://www.conventionalcommits.org/en/v1.0.0/) to create tags using the logic detailed [here](https://github.com/mathieudutour/github-tag-action#bumping)

---

### Manual Deployments 

[Manual Deployments Explained](./docs/DEPLOYDETAILED.md)

--- 

### Applying Infrastructure Changes 

[See IAC](./docs/IACHOWTO.md)

---

### Observability and Alarms

[See Obervability and Monitoring](./docs/OBSERVABILITY.md)


### Manual DB Setup

[Manual DB Setup](./docs/MANUALDBSETUP.md)

---

### License
This project is licensed under **Apache 2**, see the [LICENSE](LICENSE) file for more details.

