resource "aws_autoscaling_group" "asg" {
    name_prefix = var.name_prefix
    vpc_zone_identifier = var.vpc_zone_identifier
    target_group_arns = var.target_group_arns

    min_size =  var.min_size
    max_size = var.max_size
    desired_capacity = var.desired_capacity

    health_check_type = var.health_check_type
    health_check_grace_period = var.health_check_grace_period

    launch_template {
      id = aws_launch_template.lt.id 
      version = "$Latest"
    }

    enabled_metrics = var.enabled_metrics

   dynamic "tag" {
     for_each = merge(
        {
            Name = "${var.name_prefix}-asg"
        },
        var.tags
     )

     content {
       key = tag.key
       value = tag.value
       propagate_at_launch = true
     }
   }

   lifecycle {
     create_before_destroy = true 
     ignore_changes = [ desired_capacity]
   }
}