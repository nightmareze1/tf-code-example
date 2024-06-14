locals {
  this_region = data.aws_region.this.name

  # Rout table should either be the one for the vpc, or the ones associated to the subnets if subnets are given
  this_rts_ids_new = data.aws_route_tables.this_vpc_rts.ids

  this_rts_ids = length(var.this_subnets_ids) == 0 ? local.this_rts_ids_new : data.aws_route_table.this_subnet_rts[*].route_table_id
  this_dest_cidrs = var.destination_cidrs

  # Allow specifying route tables explicitly
  this_rts_ids_hack = length(var.this_rts_ids) == 0 ? local.this_rts_ids : var.this_rts_ids

  # In each route table there should be 1 route for each subnet, so combining the two sets
  # In each route table there should be 1 route for each subnet, so combining the two sets
  this_routes = [
    for pair in setproduct(local.this_rts_ids_hack, local.this_dest_cidrs) : {
      rts_id    = pair[0]
      dest_cidr = pair[1]
    }
  ]

  create_routes_this            = var.from_this && !local.create_associated_routes_this

  create_associated_routes_this = var.from_this && var.from_this_associated
}
