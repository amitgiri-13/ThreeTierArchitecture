resource "aws_launch_template" "lt" {
    name_prefix = "${var.name_prefix}-lt"
    image_id = var.ami_id
    instance_type = var.instance_type 
    key_name = var.key_name

    vpc_security_group_ids = var.vpc_security_group_ids
    
    dynamic "iam_instance_profile" {
        for_each = var.iam_instance_profile != null ? [1] : []
        content {
            name = var.iam_instance_profile
        }
    }

    user_data = var.user_data != null ? base64encode(var.user_data) : null

    block_device_mappings {
      device_name = var.block_device_name

      ebs {
        volume_size = var.root_volume_size
        volume_type = var.root_volume_type
        delete_on_termination = var.delete_on_termination
        encrypted = true 
      }
    }

    monitoring {
      enabled = var.enable_monitoring 
    }

    metadata_options {
      http_endpoint = "enabled"
      http_tokens = "required"
      http_put_response_hop_limit = 1
      instance_metadata_tags = "enabled"
    }

    tag_specifications {
      resource_type = "instance"

      tags = merge(
        {
          Name = "${var.name_prefix}-instance"
        },
        var.tags
      )
    }

    tag_specifications {
      resource_type = "volume"

      tags = merge(
        {
          Name = "${var.name_prefix}-volume"
        },
        var.tags
      )
    }

    lifecycle {
      create_before_destroy = true 
    }

    tags = merge(
      {
        Name = "${var.name_prefix}-lt"
      },
      var.tags 
    )
}
