DEPLOYMENT=$(shell terramate experimental get-config-value terramate.stack.name)

.PHONY: default
default: help

## create the deployment.
.PHONY: create
create:
	gcloud deployment-manager deployments create $(DEPLOYMENT) --config deployment.yaml

## update the deployment.
.PHONY: update
update:
	gcloud deployment-manager deployments update $(DEPLOYMENT) --config deployment.yaml

## delete the deployment.
.PHONY: delete
delete:
	gcloud deployment-manager deployments delete $(DEPLOYMENT)

## Display help for all targets
.PHONY: help
help:
	@awk '/^.PHONY: / { \
		msg = match(lastLine, /^## /); \
			if (msg) { \
				cmd = substr($$0, 9, 100); \
				msg = substr(lastLine, 4, 1000); \
				printf "  ${GREEN}%-30s${RESET} %s\n", cmd, msg; \
			} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
