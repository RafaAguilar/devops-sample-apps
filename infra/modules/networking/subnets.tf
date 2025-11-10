resource "aws_subnet" "private" {
  count = length(local.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = local.selected_azs[count.index]

  tags = merge(
    { Name = "${var.env}-${data.aws_region.current.id}-private-${local.selected_azs[count.index]}" },
    var.private_subnet_tags
  )
}

resource "aws_subnet" "public" {
  count = length(local.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = local.public_subnets[count.index]
  availability_zone = local.selected_azs[count.index]

  tags = merge(
    { Name = "${var.env}-${data.aws_region.current.id}-public-${local.selected_azs[count.index]}" },
    var.public_subnet_tags
  )
}