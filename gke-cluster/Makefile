DEPLOYMENT=$(shell terramate experimental get-config-value terramate.stack.name)

all:
	gcloud deployment-manager deployments create $(DEPLOYMENT) --config deployment.yaml

.PHONY: update-preview
update-preview:
	gcloud deployment-manager deployments update $(DEPLOYMENT) --config deployment.yaml --preview

.PHONY: delete
delete:
	gcloud deployment-manager deployments delete $(DEPLOYMENT)
