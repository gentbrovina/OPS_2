resource "aws_launch_template" "this" {
  name          = "default"
  image_id      = "ami-2024024020435"
  instance_type = "t2.micro"
  tags = {
    Name = "defaultl"
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "default"
  max_size                  = 4
  min_size                  = 1
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version 
  }

}
