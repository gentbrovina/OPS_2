#Define the autoschling
resource "aws_autoscaling_group" "ecs_asg" {
 vpc_zone_identifier = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]
 desired_capacity    = 4
 max_size            = 6
 min_size            = 2

 launch_template {
   id      = aws_launch_template.ecs_lt.id
   version = "$Latest"
 }

 tag {
   key                 = "AmazonECSManaged"
   value               = true
   propagate_at_launch = true
 }
}
resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
 name = "test1"

 auto_scaling_group_provider {
   auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

   managed_scaling {
     maximum_scaling_step_size = 1000
     minimum_scaling_step_size = 1
     status                    = "ENABLED"
     target_capacity           = 3
   }
 }
}

resource "aws_ecs_cluster_capacity_providers" "example" {
 cluster_name = aws_ecs_cluster.ecs_cluster.name

 capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]

 default_capacity_provider_strategy {
   base              = 1
   weight            = 100
   capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
 }
}
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_alarm" {
  alarm_name          = "ecs-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300  # 5 minutes
  statistic           = "Average"
  threshold           = 80  # Adjust the threshold as needed
  alarm_description   = "Scale out if CPU utilization is greater than 80% for 10 minutes or more."
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.my_cluster.name
  }
}
resource "aws_sns_topic" "my_topic" {
  name = "ecs-cpu-alarm-topic"
}
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.my_topic.arn
  protocol  = "email"
  endpoint  = "gentbrovina@gmail.com"
}
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale-out-policy"
  scaling_adjustment      = 1  # Increase desired capacity by 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300  # 5 minutes
  autoscaling_group_name  = aws_autoscaling_group.ecs_asg.name
}
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale-out-policy"
  scaling_adjustment      = -1  # Decrease desired capacity by 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300  # 5 minutes
  autoscaling_group_name  = aws_autoscaling_group.ecs_asg.name
}