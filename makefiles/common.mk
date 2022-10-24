DEPLOYMENT=$(shell terramate experimental get-config-value terramate.stack.name)

.PHONY: create
create:
	gcloud deployment-manager deployments create $(DEPLOYMENT) --config deployment.yaml

.PHONY: update
update:
	gcloud deployment-manager deployments update $(DEPLOYMENT) --config deployment.yaml

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
