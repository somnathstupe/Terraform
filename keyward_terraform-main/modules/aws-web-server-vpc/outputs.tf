output "vpc_id" {
  description = "ID of the VPC"
  value       = "${aws_vpc.vpc-keyward.id}"
}

output "subnet_id" {
  description = "ID of the VPC subnet"
  value       = "${aws_subnet.subnet-keyward.id}"
}
