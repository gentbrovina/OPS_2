provider "aws" {
  region = "us-east-1"  # Replace this with your desired AWS region
}

resource "aws_cloudwatch_metric_alarm" "my_alarm" {
  alarm_name                = "Gent_Alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80                                  
  alarm_description         = "This alarm triggers when CPU utilization is greater than or equal to 80% for 2 consecutive periods of 60 seconds."
  alarm_actions             = [aws_sns_topic.example_topic.arn]
}
resource "aws_sns_topic" "my_topic" {
  name = "Gent_Topic"
}

resource "aws_sns_topic_subscription" "example_topic_subscription" {
  topic_arn = aws_sns_topic.example_topic.arn
  protocol  = "email"
  endpoint  = "gent.brovina@polymaths.co"
}