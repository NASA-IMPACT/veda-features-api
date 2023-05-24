region             = "us-west-2"
registry_name      = "veda-wfs3-registry"
env                = "dev"
project_name       = "veda-features-api"
availability_zones = ["us-west-2a", "us-west-2b"]
service_port       = 8080
dns_zone_name      = "delta-backend.com"
dns_subdomain      = "firenrt"
alb_protocol       = "HTTPS"
tags               = {"project": "veda", "service": "veda-features-api-dev"}
default_secret     = {
    "noop": "boop",
}
vpc_id = "vpc-0512162c42da5e645"
