# Get all route tables from vpcs
data "aws_route_tables" "this_vpc_rts" {
  provider = aws.this
  vpc_id   = var.this_vpc_id
}

data "aws_region" "this" {
  provider = aws.this
}

# get subnets info
data "aws_subnet" "this" {
  count    = length(var.this_subnets_ids)
  provider = aws.this
  id       = var.this_subnets_ids[count.index]
}

# Get info for only those route tables associated with the given subnets
data "aws_route_table" "this_subnet_rts" {
  count     = length(var.this_subnets_ids)
  provider  = aws.this
  subnet_id = var.this_subnets_ids[count.index]
}
