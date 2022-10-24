DEPLOYMENT=$(shell terramate experimental get-config-value terramate.stack.name)

all:
	gcloud deployment-manager deployments create $(DEPLOYMENT) --config deployment.yaml

.PHONY: update
update:
	gcloud deployment-manager deployments update $(DEPLOYMENT) --config deployment.yaml

.PHONY: delete
delete:
	gcloud deployment-manager deployments delete $(DEPLOYMENT)
