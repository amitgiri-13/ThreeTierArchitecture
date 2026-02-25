data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


module "asg" {
  source = "./modules/asg"

  # General
  name_prefix = var.project_name

  # Launch Template
  ami_id                 = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = ["${module.web_sg.security_group_id}"]
  # iam_instance_profile   = 
  user_data         = file(var.user_data)
  enable_monitoring = false

  # Block Device
  block_device_name = var.block_device_name
  root_volume_size  = var.root_volume_size
  root_volume_type  = var.root_volume_type

  # Auto Scaling Group
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  vpc_zone_identifier = module.vpc.private_subnets
  target_group_arns   = [module.alb.target_group_arn]
  health_check_type   = var.health_check_type

  # Tags
  tags = var.tags
}

