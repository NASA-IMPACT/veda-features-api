output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
  depends_on = [
    aws_vpc.vpc
  ]
}

output "public_subnets_id" {
  value = aws_subnet.public_subnet[*].id
  depends_on = [
    aws_vpc.vpc
  ]
}

output "private_subnets_id" {
  value = aws_subnet.private_subnet[*].id
  depends_on = [
    aws_vpc.vpc
  ]
}

output "default_sg_id" {
  value = "${aws_security_group.default.id}"
}

output "security_groups_ids" {
  value = ["${aws_security_group.default.id}"]
  depends_on = [
    aws_security_group.default,
    aws_vpc.vpc
  ]
}
