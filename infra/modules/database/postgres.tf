resource "aws_db_subnet_group" "this" {
  for_each = toset(var.applications)

  name       = "${var.env}-${data.aws_region.current.id}-${each.value}-db-subnet-group"
  subnet_ids = var.subnets

  tags = {
    Name        = "${var.env}-${data.aws_region.current.id}-${each.value}-db-subnet-group"
    Environment = var.env
    Application = each.value
  }
}

resource "aws_security_group" "this" {
  for_each = toset(var.applications)

  name        = "${var.env}-${data.aws_region.current.id}-${each.value}-rds-sg"
  description = "Security group for ${each.value} RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "PostgreSQL access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow all outbound traffic from environment network"
  }

  tags = {
    Name        = "${var.env}-${data.aws_region.current.id}-${each.value}-rds-sg"
    Environment = var.env
    Application = each.value
  }
}

resource "aws_db_instance" "main" {
  for_each = toset(var.applications)

  identifier     = "${var.env}-${data.aws_region.current.id}-${each.value}-db"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = var.storage_encrypted

  db_name  = replace("${var.env}_${data.aws_region.current.id}_${each.value}_database", "-", "_")
  username = "admin_${var.env}_${each.value}_${random_string.this[each.value].result}"
  password = random_password.this[each.value].result

  db_subnet_group_name   = aws_db_subnet_group.this[each.value].name
  vpc_security_group_ids = [aws_security_group.this[each.value].id]
  publicly_accessible    = false

  multi_az                = contains(["failover", "robust"], var.redundancy)
  backup_retention_period = var.snapshot_retention_days
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.env}-${data.aws_region.current.id}-${each.value}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Name        = "${var.env}-${data.aws_region.current.id}-${each.value}-db"
    Environment = var.env
    Application = each.value
    Role        = "ReadWriteReplica"
  }

  lifecycle {
    ignore_changes = [
      final_snapshot_identifier
    ]
  }
}

resource "aws_db_instance" "read_replica" {
  for_each = var.redundancy == "robust" ? toset(var.applications) : toset([])

  identifier          = "${var.env}-${data.aws_region.current.id}-${each.value}-db-replica"
  replicate_source_db = aws_db_instance.main[each.value].identifier
  instance_class      = var.instance_class
  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name        = "${var.env}-${data.aws_region.current.id}-${each.value}-db-replica"
    Environment = var.env
    Application = each.value
    Role        = "ReadReplica"
  }
}

