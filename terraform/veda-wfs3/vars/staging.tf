region             = "us-west-2"
registry_name      = "veda-wfs3-registry"
env                = "staging"
project_name       = "veda-wfs3"
availability_zones = ["us-west-1a", "us-west-1b"]
service_port       = 8080
tags               = {"project": "veda", "service": "wfs3"}
default_secret     = {
    "noop": "boop",
}
