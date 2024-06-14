resource "aws_route" "this_routes" {
  provider = aws.this
  count                     = local.create_routes_this ? length(local.this_routes) : 0
  route_table_id            = local.this_routes[count.index].rts_id
  destination_cidr_block    = local.this_routes[count.index].dest_cidr
  vpc_peering_connection_id = var.aws_resource_id
}
