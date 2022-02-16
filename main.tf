#################################################################################################
# Note: these resources are in the account that hosts the service
#################################################################################################

data "aws_caller_identity" "current" {
  provider = aws.client_account
}

locals {
  allowed_principal = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}

resource "aws_vpc_endpoint_service" "service" {
  acceptance_required        = false
  network_load_balancer_arns = [module.nlb.lb_arn]
  allowed_principals         = [local.allowed_principal]

  provider = aws.service_account
}

module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.3"

  name               = "${var.name_prefix}-private-link"
  load_balancer_type = "network"
  vpc_id             = var.service_vpc_id
  subnets            = var.service_subnets
  internal           = true

  http_tcp_listeners = [
    {
      port     = var.client_port
      protocol = "TCP"
    },
  ]

  target_groups = [
    {
      name             = "${var.name_prefix}-private-link"
      backend_protocol = "TCP"
      backend_port     = var.service_port
      target_type      = "ip"
    },
  ]

  providers = {
    aws = aws.service_account
  }

}

module "populate_network_lb_target_group_with_address" {
  source                    = "./populate_nlb_tg_with_address_from_dns"
  service_hostname          = var.service_hostname
  nlb_tg_arn                = join("", module.nlb.*.target_group_arns[0])
  max_lookup_per_invocation = "10"
  resource_name_prefix      = var.name_prefix
  providers = {
    aws = aws.service_account
  }

}

#################################################################################################
# Note: these resources are in the account that is accessing the servicre
#################################################################################################

resource "aws_vpc_endpoint" "client" {
  vpc_id             = var.client_vpc_id
  service_name       = aws_vpc_endpoint_service.service.service_name
  auto_accept        = true
  vpc_endpoint_type  = "Interface"
  security_group_ids = var.client_security_group_ids
  subnet_ids         = var.client_subnets

  tags = merge(var.tags, {
    "Name" : "${var.name_prefix}-private-link"
  })

  provider = aws.client_account
}
