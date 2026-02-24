data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}


module "asg" {
  source = "./modules/asg"

  # General
  name_prefix = "terra-asg"

  # Launch Template
  ami_id                 = data.aws_ssm_parameter.amazon_linux_2.value
  instance_type          = "t2.micro"
  key_name               = "privatekey"
  vpc_security_group_ids = ["${module.web_sg.security_group_id}"]
  # iam_instance_profile   = var.iam_instance_profile
  user_data              = file("./userdata.sh")
  enable_monitoring      = false

  # Block Device
  block_device_name = "/dev/xvda"
  root_volume_size = 20
  root_volume_type = "gp2"

  # Auto Scaling Group
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  vpc_zone_identifier = module.vpc.private_subnets
  #vpc_zone_identifier = ["${module.vpc.private_subnets[0]}","${module.vpc.private_subnets[1]}"]
  target_group_arns   = [module.alb.target_group_arn]
  health_check_type   = "EC2"

  # Tags
  tags = {}
}

