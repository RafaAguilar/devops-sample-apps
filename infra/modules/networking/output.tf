output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "availability_zones" {
  value = local.selected_azs
}

output "vpc_cidr_block" {
  value = var.vpc_cidr_block
}