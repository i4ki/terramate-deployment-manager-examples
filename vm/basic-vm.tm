# Example of creating a virtual machine.

stack {
    name = "basic vm"
}

generate_file "vm.yaml" {
  lets {
    machine = "n1-standard-1"
    deployment = {
      resources = [
        {
          name = terramate.stack.name
          type = "compute.v1.instance"
          properties = {
            zone        = global.project.default_zone
            machineType = "zones/${global.project.default_zone}/machineTypes/${let.machine}"
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

    content = tm_join(
        "\n", 
        [global.generated_header, tm_yamlencode(let.deployment)]
    )
}
