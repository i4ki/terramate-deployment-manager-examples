# Example of creating a virtual machine.

stack {
    name = "basic vm"
}

generate_file "vm.yaml" {
  lets {
    deployment = {
      resources = [
        {
          name = "vm-created-by-deployment-manager"
          type = "compute.v1.instance"
          properties = {
            zone        = "us-central1-a"
            machineType = "zones/us-central1-a/machineTypes/n1-standard-1"
            disks = [
              {
                deviceName = "boot"
                type       = "PERSISTENT"
                boot       = true
                autoDelete = true
                initializeParams = {
                  sourceImage = "projects/debian-cloud/global/images/family/debian-11"
                }
              }
            ]
            networkInterfaces = [
              {
                network = "global/networks/default"
              }
            ]
          }
        }
      ]
    }
  }

  content = tm_yamlencode(let.deployment)
}
