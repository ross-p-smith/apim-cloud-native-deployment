SHELL := /bin/bash

.PHONY: help
.DEFAULT_GOAL := help

ENV_FILE := .env
ifeq ($(filter $(MAKECMDGOALS),config clean),)
	ifneq ($(strip $(wildcard $(ENV_FILE))),)
		ifneq ($(MAKECMDGOALS),config)
			include $(ENV_FILE)
			export
		endif
	endif
endif

help: ## 💬 This help message :)
	@grep -E '[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-23s\033[0m %s\n", $$1, $$2}'

infra: ## 🚀 Deploy the API Ops Infrastructure
	@echo -e "\e[34m$@\e[0m" || true
	@./scripts/deploy.sh

aso: ## ⚙️ Setup Azure Service Operator
	@echo -e "\e[34m$@\e[0m" || true
	@./scripts/aso.sh

