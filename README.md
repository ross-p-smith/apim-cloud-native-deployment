# Deploying API Management artefacts in a cloud native manner

This repository create an Azure Kubernetes Service and an API Management to demonstrate how you would use the Kubernetes API to create APIs in API Management

## Repository Structure

```text
📂
├── [/.devcontainer](./.devcontainer/) contains the dev container with the installs necessary to run the project.
├── [/apim_artifacts](./apim_artifacts/) this folder is created by the demo.
├── [/apim_templates](./apim_templates/) holds the apim configuration that ASO will deploy.
├── [/infrastructure](./infrastructure/) contains the Terraform infrastructure.
├── [/scripts](./scripts/) contains scripts used to deploy project infrastructure.
├── [Makefile](./Makefile) defines the set of operations that can be executed from the command line.
└── [.env.example](./.env.example) contains the environment variables necessary to run the project.
```

This repository assumes that you are running this inside a VSCode DevContainer.

### Running Locally

A makefile provides a frontend to interacting with the project. This makefile is self documentating, and has the following targets:

```text
help                    💬 This help message :)
infra                   🚀 Deploy the API Ops Infrastructure
aso                     ⚙️ Setup Azure Service Operator
deploy_apim_artifacts   🚀 Deploy APIM Artifacts
```

### Deploy the Infrastructure

Make a copy of the `.env.example` and call it `.env`; then define an Azure region, unique `prefix` and your Azure Subscription Id. Next run the following from a terminal: -

`make infra`

This will install APIM - go make yourself some lunch!

### Install Azure Service Operator in your cluster

Run the following from a terminal: -

`make aso`

### Use kubectl to apply configuration to AKS which configures APIM!

Run the following from a terminal: -

`make deploy_apim_artifacts`