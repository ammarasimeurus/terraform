output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public
}

output "private_subnet_ids" {
  value = aws_subnet.private
}
output "vpc_sg_id" {
  value = aws_security_group.allow_all.id
}