resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}-sg"
  description = "${var.name}-${var.env}-sg" #"Allow TLS inbound traffic"
  vpc_id      = var.vpc_id                  #aws_vpc.main.id

  ingress {
    description = "REDIS" # "TLS from VPC"
    from_port   = var.port_number
    to_port     = var.port_number
    protocol    = "tcp"
    cidr_blocks = var.allow_db_cidr #[aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-sg" })
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name}-${var.env}"
  subnet_ids = var.subnets #[aws_subnet.frontend.id, aws_subnet.backend.id]

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-sng" })
}

resource "aws_elasticache_parameter_group" "main" {
  family      = "redis6.x"
  name        = "${var.name}-${var.env}-epg"
  description = "${var.name}-${var.env}-epg"
  tags        = merge(var.tags, { Name = "${var.name}-${var.env}-epg" })
}


resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.name}-${var.env}-elasticache"
  description                = "${var.name}-${var.env}-elasticache"
  engine               = "redis"
  engine_version       = var.engine_version
  node_type                  = var.node_type
  port                       = 6379
  parameter_group_name       = aws_elasticache_parameter_group.main.name
  automatic_failover_enabled = true
  num_node_groups         = var.num_node_groups
  replicas_per_node_group = var.replicas_per_node_group
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.main.id]
  at_rest_encryption_enabled = true
  kms_key_id = var.kms_arn
  tags                 = merge(var.tags, { Name = "${var.name}-${var.env}-elasticache" })
}

# resource "aws_rds_cluster" "main" {
#   cluster_identifier      = "${var.name}-${var.env}-rds"
#   engine                  = "aurora-mysql"
#   engine_version          = var.engine_version
# #   availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
#   database_name           = "rdsdb"
#   master_username         = data.aws_ssm_parameter.db_user.value
#   master_password         = data.aws_ssm_parameter.db_pass.value
#   backup_retention_period = 5
#   preferred_backup_window = "07:00-09:00"
#   vpc_security_group_ids          = [aws_security_group.main.id]
#   db_subnet_group_name            = aws_db_subnet_group.main.name
#   skip_final_snapshot = true
#   storage_encrypted = true
#   kms_key_id = var.kms_arn
#   tags        = merge(var.tags, { Name = "${var.name}-${var.env}-rdsc" })
# }

# resource "aws_rds_cluster_instance" "cluster_instances" {
#   count              = var.instance_count
#   identifier         = "aurora-cluster-main-${count.index}"
#   cluster_identifier = aws_rds_cluster.main.id
#   instance_class     = var.instance_class
#   engine             = aws_rds_cluster.main.engine
#   engine_version     = aws_rds_cluster.main.engine_version
#   tags        = merge(var.tags, { Name = "${var.name}-${var.env}-rds-${count.index+1}" })
# }

# resource "aws_docdb_cluster" "main" {
#   cluster_identifier              = "${var.name}-${var.env}" #"my-docdb-cluster"
#   engine                          = "docdb"
#   engine_version                  = var.engine_version
#   master_username                 = data.aws_ssm_parameter.db_user.value #"foo"
#   master_password                 = data.aws_ssm_parameter.db_pass.value #"mustbeeightchars"
#   backup_retention_period         = 5
#   preferred_backup_window         = "07:00-09:00"
#   skip_final_snapshot             = true
#   db_subnet_group_name            = aws_docdb_subnet_group.main.name
#   db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.main.name
#   storage_encrypted               = true
#   kms_key_id                      = var.kms_arn
#   port                            = var.port_number
#   vpc_security_group_ids          = [aws_security_group.main.id]
#   tags                            = merge(var.tags, { Name = "${var.name}-${var.env}-dc" })
# }

# resource "aws_docdb_cluster_instance" "cluster_instances" {
#   count              = var.instance_count
#   identifier         = "${var.name}-${var.env}"  #"docdb-cluster-demo-${count.index}"
#   cluster_identifier = aws_docdb_cluster.main.id
#   instance_class     = var.instance_class #"db.r5.large"
# }
