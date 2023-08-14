
# Create Database Subnet Group
# terraform aws db subnet group
resource "aws_db_subnet_group" "database-subnet-group" {
  name         = "database subnets"
  subnet_ids   = [aws_subnet.private-subnet-3.id, aws_subnet.private-subnet-4.id]
  description  = "Subnets for Database Instance"

  tags   = {
    Name = "Database Subnets"
  }
}

# Get the Latest DB Snapshot
# terraform aws data db snapshot
data "aws_db_snapshot" "latest-db-snapshot" {
  db_snapshot_identifier = "${var.database-snapshot-identifier}"
  most_recent            = true
  snapshot_type          = "manual"
}
resource "aws_security_group" "db_security_group" {
  name_prefix = "db-"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust this to your desired access
  }

  // Egress rule to allow outbound traffic (example: all traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust this to your desired egress rules
  }
}

# Create Database Instance Restored from DB Snapshots
# terraform aws db instance
resource "aws_db_instance" "database-instance" {
  instance_class          = "${var.database-instance-class}"
  skip_final_snapshot     = true
  availability_zone       = "eu-central-1a"
  identifier              = "${var.database-instance-indetifier}"
  snapshot_identifier     = data.aws_db_snapshot.latest-db-snapshot.id
  db_subnet_group_name    = aws_db_subnet_group.database-subnet-group.name
  multi_az                = "${var.multi-az-deployment}"
  vpc_security_group_ids  = [aws_security_group.db_security_group.id]
}
