# project wide configuration

globals "project" {
  default_zone      = "us-central1-a"
  enable_monitoring = true
  enable_logging    = true
}

globals {
  generated_header = <<-EOF
        # TERRAMATE: GENERATED AUTOMATICALLY DO NOT EDIT
        # TERRAMATE: originated from generate_file block on ${terramate.stack.path.absolute}
    EOF
}
