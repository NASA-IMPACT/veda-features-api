region             = "us-west-2"
registry_name      = "veda-wfs3-registry"
env                = "dev"
project_name       = "veda-wfs3"
availability_zones = ["us-west-1a", "us-west-1b"]
service_port       = 8080
dns_zone_name      = ""
dns_subdomain      = ""
alb_protocol       = "HTTPS"
tags               = {"project": "veda", "service": "wfs3"}
default_secret     = {
    "noop": "boop",
}
