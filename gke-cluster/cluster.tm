# Example of creating a GKE cluster

stack {
  name = "gke-cluster"
  description = "Basic example of a GKE cluster provisioning"
}

generate_file "deployment.yaml" {
  lets {
    autoScaling       = false
    autoRepair        = false
    autoUpgrade       = false
    httpLoadBalancing = true
    node = {
      machineType  = "g1-small"
      diskSizeGb   = 10
      imageType    = "cos" # container optimized OS
      version      = "1.22.12-gke.2300"
      initialCount = 1
    }
    properties = {
      zone = global.project.default_zone

      # The {for ...} used below is needed to get rid of null values in the object.
      # This would be greatly simplified if Terramate provides a `tm_compact()`
      # that removes null entries from list/map/objects.
      cluster = { for k, v in {
        monitoringService = tm_try(global.monitoringService, null)
        loggingService    = tm_try(global.loggingService, null)
        addonsConfig = {
          httpLoadBalancing = {
            disabled = !let.httpLoadBalancing
          }
        }
        locations             = tm_try(tm_split(",", global.project.locations), null)
        currentMasterVersion  = tm_try(let.currentMasterVersion, null)
        initialClusterVersion = tm_try(let.initialClusterVersion, null)
        maintenancePolicy = tm_ternary(
          tm_can(global.maintenanceWindowDuration),
          {
            window = {
              dailyMaintenanceWindow = {
                startTime = "00:00"
                duration  = global.maintenanceWindowDuration
              }
            }
          },
          null,
        )

        nodePools = [
          {
            name = "${terramate.stack.name}np"
            config = {
              machineType = let.node.machineType
              diskSizeGb  = let.node.diskSizeGb
              oauthScopes = [
                "https://www.googleapis.com/auth/devstorage.read_only"
              ]
              imageType = let.node.imageType
            }
            version          = tm_try(let.node.version, null)
            initialNodeCount = let.node.initialCount
            management = {
              autoUpgrade = let.autoUpgrade
              autoRepair  = let.autoRepair
            }
          }
        ]
      } : k => v if v != null }
    }
    deployment = {
      resources = [
        {
          name       = terramate.stack.name
          type       = "gcp-types/container-v1:projects.zones.clusters"
          properties = let.properties
        },

        # gke type provider
        {
          name = "${terramate.stack.name}-gke-type"
          type = "gcp-types/deploymentmanager-v2beta:typeProviders"
          properties = {
            descriptorUrl = "https://$(ref.${terramate.stack.name}.endpoint)/openapi/v2"
            options = {
              validationOptions = {
                schemaValidation = "IGNORE_WITH_WARNINGS"
              }
              inputMappings = [
                {
                  fieldName = "Authorization"
                  location  = "HEADER"
                  value     = "$.concat(\"Bearer \", $.googleOauth2AccessToken())"
                },
                {
                  fieldName   = "metadata.resourceVersion"
                  location    = "BODY"
                  methodMatch = "^(put|patch)$"
                  value       = "$.resource.self.metadata.resourceVersion"
                },
                {
                  fieldName   = "id"
                  location    = "PATH"
                  methodMatch = "^(put|get|delete|post|patch)$"
                  value       = "$.resource.properties.id"
                },
                {
                  fieldName   = "name"
                  location    = "PATH"
                  methodMatch = "^(put|get|delete|post|patch)$"
                  value       = "$.resource.properties.metadata.name"
                },
                {
                  fieldName   = "namespace"
                  location    = "PATH"
                  methodMatch = "^(put|get|delete|post|patch)$"
                  value       = "$.resource.properties.namespace"
                },
              ],
              customCertificateAuthorityRoots = [
                "$(ref.${terramate.stack.name}.masterAuth.clusterCaCertificate)"
              ]
            }
          }
        },
      ]
    }
  }

  content = tm_join(
    "\n",
    [global.generated_header, tm_yamlencode(let.deployment)]
  )
}
