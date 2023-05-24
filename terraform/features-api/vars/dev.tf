region             = "us-west-2"
registry_name      = "veda-wfs3-registry"
env                = "west2-staging"
project_name       = "veda-wfs3"
availability_zones = ["us-west-2a", "us-west-2b"]
service_port       = 8080
dns_zone_name      = "delta-backend.com"
dns_subdomain      = "firenrt"
alb_protocol       = "HTTPS"
tags               = {"project": "veda", "service": "wfs3"}
default_secret     = {
    "noop": "boop",
}
vpc_id = "none"
