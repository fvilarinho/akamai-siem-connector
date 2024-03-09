## Akamai SIEM Connector

## 1. Introduction
Customers want to access, analyze and process their security events to build reports, dashboards or even to get insights
in real-time to take actions in a fast manner.

What if we could provide an easier and robust way to collect this data?

That's what you'll get here!

This application provides a reliable and scalable way to collect Akamai Security Events (WAF, DDoS, BOT, etc.) and 
easily store it into SIEMs platforms.

## 2. Maintainers
- [Felipe Vilarinho](https://www.linkedin.com/in/fvilarinho)
- [Leandro Cassiano](https://www.linkedin.com/in/leandro-cassiano-alves-652a795b/)

If you want to collaborate in this project, reach out us by e-Mail.

You can also fork and customize this project by yourself once it's opensource. Follow the requirements below to set up 
your build environment.

## 3. Requirements

### To build, package and publish
- [`NodeJS 20.x or later with npm`](https://nodejs.org)
- [`JDK 17 or later`](https://www.oracle.com/java/technologies/downloads)
- [`Docker 24.x or later`](https://www.docker.com)
- `Any linux distribution with Kernel 5.x or later` or
- `MacOS - Catalina or later` or
- `MS-Windows 10 or later with WSL2`
- `Dedicated machine with at least 4 CPU cores and 8 GB of RAM`

Just execute the shell script `build.sh` to start the building process. Execute `package.sh` to start the packaging, and 
execute`publish.sh` to publish the built packages in the repository.

The following variables must be set in your build environment file that is located in `iac/.env`.

- `DOCKER_REGISTRY_URL`: Define the Docker Registry Repository URL to build and store the container images. (For 
example, to use [Docker HUB](https://hub.docker.com), the value will be `docker.io`. To use 
[GitHub Packages]('https://github.com'), the value will be `ghcr.io`. Please check the instructions of your Docker 
Registry repository).
- `DOCKER_REGISTRY_ID`: Define the Docker Registry Repository Identifier (Usually it's the username, but check the 
instructions of your Docker Registry repository).
- `BUILD_VERSION`: Define the version of the container images.
- `IDENTIFIER`: Define the identifier (prefix) of the container images.

The following environment variable must be set in your operating system.
- `DOCKER_REGISTRY_PASSWORD`: Define the Docker Registry Repository Password.

#### Latest build status
- [![CI/CD Pipeline](https://github.com/fvilarinho/akamai-siem-connector/actions/workflows/pipeline.yml/badge.svg)](https://github.com/fvilarinho/akamai-siem-connector/actions/workflows/pipeline.yml)

### To setup
- [`dialog 1.3.x or later`](https://invisible-island.net/dialog)
- [`jq 1.7.x or later`](https://stedolan.github.io/jq)
- [`yq 4.18.x or later`](https://mikefarah.gitbook.io/yq)
- [`curl 8.5.x or later`](https://curl.se)
- [`Terraform 1.5.x or later`](https://www.terraform.io)
- [`kubectl 1.29.x or later`](https://kubernetes.io/docs/tasks/tools)
- `Any linux distribution with Kernel 5.x or later` or
- `MacOS - Catalina or later` or
- `MS-Windows 10 or later with WSL2`

To start the setup, you just need to execute the script `setup.sh` and follow the instructions.

### To deploy
Just execute the shell script `deploy.sh` (after the setup) to start the provisioning, and execute `undeploy.sh` for
de-provisioning.

After the provisioning is complete, just execute the following commands:
- `export KUBECONFIG=iac/.kubeconfig` to specify how you'll connect in the Akamai Connected Cloud LKE cluster.
- `kubectl get nodes -o wide` to list the LKE cluster nodes.
- `kubectl get pods -n akamai-siem-connector -o wide` to get the details of stack pods.

To access the stack UI (after all pods started), get the hostname by executing the command `kubectl get service ingress -n akamai-siem-connector -o json | jq -r ".status.loadBalancer.ingress[0].hostname"`. 
Then just open your browser and type the URL: `[http|https]://<hostname>` and the login prompt will appear.

To access the administration UI, just open your browser and type the URL: `[http|https]://<hostname>:[9000|9443]` and the login prompt will appear.

## 5. Architecture
Follow this [diagram](https://viewer.diagrams.net/?tags=%7B%7D&highlight=0000ff&edit=_blank&layers=1&nav=1&title=Untitled%20Diagram.drawio#R7V1rd6M2E%2F41%2BZg9gADbH3PdTbtp03V79vLlPTLINg1GXpATu7%2F%2BlUDYwMgOiblt8PacFMTFoGdmNPPMSJyhq8X6Y4iX83vqEv%2FM0Nz1Gbo%2BM4whGvK%2FomEjGwZ20jALPTdp0ncNY%2B8%2FIhs12bryXBLlTmSU%2Bsxb5hsdGgTEYbk2HIb0OX%2FalPr5X13iGQENYwf7sPWr57K5fAtjsGv%2FRLzZPP1l3R4lRxY4PVm%2BSTTHLn3ONKGbM3QVUsqSrcX6ivii79J%2BSa673XN0%2B2AhCViZC%2F723B%2BTz9ri9ir89M%2F5l%2B9r48v1uW4lt3nC%2Fkq%2BMXOWZ%2BJWts9vezkJ%2BdZMbKU9bNzyrWi1IPK12CbtK0bW4sQ5W%2Fi8Qeeb2PdmAd92%2BDOSkDc8kZB5vHcv5IGF57ri8suQRN5%2FeBLfSuP7S%2BoFLMbOujyzrsW9VoxGiXyIW0cspI%2FkivqU3%2Fc6oIG4y9Tz%2FWITDZgUK11cB7tN9qR4NLLONMlu%2FEjogrBww0%2BRR01D9pqUaduWED%2FvJERPBXiekQ5TtmEplLPtrXe48Q0JnRrGT%2Fhp9ON8%2FNeGEfTzx%2FP978bj3bkOULx4xAvs8bbx3c09%2F9%2FFwx3%2FexO4cccC6EK6Clziyr59nnuMjJfYEUefuV7nUc12qVno9TMDuZgMpw6AiB%2BxnSGZTKsBwRiM8iBADJCmwMCuDQMNgPAbnUS85a8VWUFt4fZgKTadje%2Fxvg%2FRyx0%2FSVD6PNk2YOdxFmP354rx22yVQ6JjKRSgiJZFhq6pQmtoTJBtV4OWnQdLhZatAGtQF1iGDcACABGXjwRyl4ZsTmc0wP7NrvVypzXCZO3O%2BUzpUiLxL2FsI7tfWLA8oBHDIbsQw5QQBB9Hkeekzbeen562F4CIrkKHHBJK%2BZ78hjPCDp0oBzTx0gcBDYmPmfeUHx4rx8dEbcBB1h77ltn%2BLm71wZJ712t553hnk%2B4E%2FH2%2FZXcyV4nd3WXxXnpdDno5VmVx15rBHVlt4a72R%2BBI1oYgFEe47ugpMruFl3HCq6N4HXzuDF5XiTcf1usTNuJloKKbMTA%2BWMDR0A2VW2jV5WkMWxnJ0lFpu1NuVIr3Hkjo8ZcXARscqmrRpkFZL0XrljYN9mmTeJm5%2BPtvEgJEzpy4K59DKjiIMCYsfD8Op%2FeEBcuQOiSKSgQFe2KAF%2Fz%2BqSX%2Bk%2Bdl2pN%2Fyugt%2FleNpurDoqaW1dPawrcRwNIJaVCgQjJI2T9XgrqJ%2B%2B88Cbgu%2BAm6vlzHfZQeT%2FmTiIRPntNf1kRHdg5yU7MB5KoYsDbSxIDc1%2BInY9Uh3neeTNfzSo40qOSDJhFHkKKpHPFAZdT7gjjSXka8UR1P0w%2FvnedBRlkPqi0HSh0%2Btkrz7Kid75kjapqn8QizPKJ2p3zi9LmzuYgV94UDYd0YiW0BNwWGJiD9KJKAhuZ7kxDL3%2B6fL1zMZOgDRTqpUV%2FYHHRHLbWDallSDXck7S4C%2Fp49ticcPkJ9zbYMsrz0IcnzpUJmFXyxrUClt0ge9GGbHczKz%2FYxjjALJjALt4Q5whCQJyIcGkOb4CgOkOOoi3lxFE2n04iweCMbU%2FfUVJhW50yF1aapaCJR8zIlVnn2Jk3KvMwud2zshxH1VUiSUV8SYRxJ3idSSVOFllxYrPypNeilfltm12gxBBMGNxKhSiLmU22EMTA6VhxhwrH6RJNUSZOYw47RJCbU8moRX64mvhfNe4u4bXcNcUiMzRlbwoG3LwgZBZ3UTWiFLQVCqDaEYEKq3wiBELZthAY6wKKj7OU%2B%2FmMX7ahjnyKK9YY9KXgvhj1pFNyRsMeCaaWHJEwRmf6ChPz6VTXIHgK9a7amxmonbfBGElFJIBzUrDryCVbZfELHOAWrG5Xa3cUrtT5dwQvmf0rXRElyxwtmAOJ%2B8j%2BodX7XaoAL6HWRDIgMRyMAeaNFMhYsajyxP7WyPwrE6%2BIClFUYqBMj7BFD5ajkUGl3bKiEEf5DmhnhdxRzmoVUiZ8O3BgPGu5G0V4nSooxidn6QGnDIPCC93kM1e94%2BohfaT3NPdbzUvQqDCvbyJi0F5EWKmYsFfqqyb%2Bj2tAftWEyt1TQ2RvS4K%2BcGdJ4AGSXnRSS0hEdseo29J%2FGMtJ5D2xQceZGo2yQ0n0x2qlWq4sNAtWllfOsKWK%2F2nQrG%2BaslOUl8Z%2Ft%2FKp%2BO0qW%2FSG%2FWImKUhhaDTpKA0gQ4WgTONzBwQvR5cEkWiYOTxXRZkh%2BrkjU32izWF1sINWc2EZzzwMYcKYScEK8ApXXi4iXqyeqD2%2FIIZ40vs7lqQqxMdIbw189yweGxm14bHVO4VG%2Bt2IKgPK81uIXtTvdq6qGSr3to6QgtdodEQNos2%2FWSw7suwhii%2FThUCtLH9YVxEIquG0TWTXJc8j0dZi5P%2FTYB3Lc20lNMryMs9wZGt8F8PYjHi1q3qC05tXmnUBL9%2FISqH2vZy76mJYixlAy8PU5mbBO6BRkNCcAg5KTVupLYpsnt7VKtzV1R1%2F0W1G3hmbFOk5jZd68aNy9YHuKXDM5rkm79GbXmGHRi%2FzxpzRcnEbueH%2FU%2Bsid%2Bsgnk9%2BKyR%2FaRrsm34Bu%2BGnWWqWIaznAkQFTvc2O8VDhATbCri7Lv%2Fv2yxESkrPsxxmU%2Be9CPmU0gp1iqTxfsOJGdd1Sgl89iqOB3XkYnpcFrL3OgksU3HtOSCM6FYZjLNYpCsQnTPaM8S3PSJ9Op4aj%2FLaCa09sSz3UHwvWdjk%2FMyf5OhT8oQLKoVETkrDOJjX7ohOPMvw3Po64%2BY4IDsUSNUV3IvEM%2F1ySYHuGn1x%2Bm%2Fx0cpeuCtGbONaKhMjQOiVDijVAL76OhSFAKcwOXSx53CKGhxOeCjyH3QJUsV7JGk8I3h%2B29dikIw11Cz0YvH8hCxpXeI03kU%2F3TwzrsQ6iUbd0ULEMVMyo3%2FZ7%2FQLTyPtPIxvWZahmelWxfoEap24sjlt1XUYLyUR5aWHNRWOUDxVtvZA9TkjYKtZcVKfwYbgsl9vS7nGAZ%2B8ilV%2BMx61hWVqyrlS%2B2U4m4o316M1XRSGopgfFtyOJhXZWuuwuPK19MO7gY2ds3TWO5hOKQxe6HL%2B%2BmWu%2FYqmdRaKb1wfFl74OSmBXFKLEuilp7IQdJmT2eFr49asfFKUaAak2m0wpnpbFK%2FI7qFDnocPJI3UtuqZG6LQs3mGERm0jpFgOrd8IFb%2BDpLJyjSKkWKsAgFN3HtXW85kA21I4NClDkksNVrHusVpwYbwMuuXNnqNalg7D86o8atOdpb%2Bms7TXd1YVX5U%2FtntTE6vnRNWABlbledeXwlZ8S2Pl%2B%2BKBFzGv48Lqtok4evGIF9h7L3a4InDNPLiK0bPZQuYyCx5WqliVZS6OViwFddesYsGSgjvB5zpY1IZOSFbBFNMDcjqWJI%2FhSVeriFHV55ZPWpjzBqAW6gpRsGoThRK5kSq1sLos8NFaqCvmcjSrhjDEKze%2Bpbr1bkKNmoY4Q%2BFq1zXGfX7QyO0%2FX9HXzf%2Fcb%2Bzvm093f2zO282QvHLlKwiLgjtUvmbZhGR765kfeuz87MZY2uCo9esx6cU1dk17oFgQpTYuXdnjewomfgUjVgEiqMCP2AofXMUCV8GPKOGAHnif4DALZQuWItVUERx8N6Si8nZ77CM3GvN76hJxxv8B) to check out the architecture.

## 6. Settings
If you want to customize the stack by yourself, just edit the following files in the `iac` directory:
- `main.tf`: Defines the required provisioning providers.
- `variables.tf`: Defines the provisioning variables.
- `linode.tf`: Defines the provisioning settings of Akamai Connected Cloud.
- `lke.tf`: Defines the provisioning of the LKE cluster.
- `lke-stack-storages.yml`: Defines how the stack storages (Block Storage) will be deployed in the Akamai Connected 
Cloud.
- `lke-stack-deployments.yml`: Defines how the stack deployments (pods) will be deployed in the Akamai Connected Cloud.
- `lke-stack-services.yml`: Defines how the stack services (ingress and stack services) will be deployed in the Akamai
Connected Cloud.
- `auth0.tf`: Defines the provisioning of the auth0.com settings.
- `docker-compose.yml`: Defines how the stack will be built.

## 7. Other resources
- [`Akamai Techdocs`](https://techdocs.akamai.com)
- [`Akamai Connected Cloud`](https://www.linode.com)

And that's it! Have fun!