output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.lt.id
}

output "launch_template_arn" {
  description = "ARN of the launch template"
  value       = aws_launch_template.lt.arn
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.lt.latest_version
}

output "autoscaling_group_id" {
  description = "ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.name
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.asg.arn
}
