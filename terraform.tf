// Fargate cluster
module "fargate" {
  source = "github.com/DevBOFH/terraform-aws-ecs-fargate.git?ref=v1.0.0"

  namespace = "company"
  stage     = "prod"
  service   = "retool"
  region    = "us-east-1"
  hostname  = "retool.prod.domain.tld"

  vpc_id              = "vpc-xxxxxxxx"
  private_subnets_ids = ["subnet-xxxxxxxx", "subnet-xxxxxxxx"]
  public_subnets_ids  = ["subnet-xxxxxxxx", "subnet-xxxxxxxx"]

  container_name   = "retool"
  container_image  = "${var.ecr_retool_registry_url}:${var.service_version}"
  container_port   = 3000
  essential        = true
  internal         = true
  certificate_arn  = var.acm_certificate_arn
  ssm_secrets_path = "/${var.service}/"

  environment = [
    {
      name  = "POSTGRES_DB"
      value = module.database.database_name
    },
    {
      name  = "POSTGRES_HOST"
      value = module.database.master_host
    },
    {
      name  = "POSTGRES_PORT"
      value = "5432"
    },
    {
      name  = "POSTGRES_USER"
      value = module.database.master_username
    },
    {
      name  = "AWS_ENV_PATH"
      value = "/${var.service}/"
    }
  ]

  secrets = [
    {
      name      = "POSTGRES_USER"
      valuefrom = module.database.master_username
    },
    {
      name      = "POSTGRES_PASSWORD"
      valuefrom = module.aurora.aurora_password_arn
    }
  ]

}

// Route53 DNS Records
resource "aws_route53_record" "this" {
  zone_id = var.route53_zone_id
  name    = "retool.domain.tld"
  type    = "CNAME"
  ttl     = "60"

  records = ["${module.fargate.lb_dns_name}"]
}

// Aurora DB Cluster
module "database" {
  source = "github.com/cloudposse/terraform-aws-rds-cluster.git?ref=v0.29.0"

  name            = "retool"
  engine          = "aurora-postgresql"
  cluster_family  = "aurora-postgresql10.7"
  cluster_size    = "2"
  namespace       = "eg"
  stage           = "dev"
  admin_user      = "admin1"
  admin_password  = "Test123456789"
  db_name         = "retool"
  db_port         = "5432"
  instance_type   = "db.t3.medium"
  vpc_id          = "vpc-xxxxxxxx"
  security_groups = ["sg-xxxxxxxx"]
  subnets         = ["subnet-xxxxxxxx", "subnet-xxxxxxxx"]
  zone_id         = "xxxxxxxx"
}
