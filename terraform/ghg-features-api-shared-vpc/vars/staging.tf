region             = "us-west-2"
registry_name      = "veda-wfs3-registry"
env                = "west2-staging"
project_name       = "veda-wfs3"
availability_zones = ["us-west-2a", "us-west-2b"]
service_port       = 8080
dns_zone_name      = ""
dns_subdomain      = ""
alb_protocol       = "HTTPS"
tags               = {}
default_secret     = {
    "noop": "boop",
}
