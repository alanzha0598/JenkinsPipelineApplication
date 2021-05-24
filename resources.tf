#Based on the work from https://github.com/arbabnazar/terraform-ansible-aws-vpc-ha-wordpress

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
 # profile = var.aws_profile
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region  = var.aws_region
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_launch_configuration" "webapp_lc" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix   = "${terraform.workspace}-ddt-lc-"
  image_id      = "${data.aws_ami.aws_linux.id}"
  instance_type = var.asg_instance_size

  security_groups = [
    "${aws_security_group.webapp_http_inbound_sg.id}",
    "${aws_security_group.webapp_ssh_inbound_sg.id}",
    "${aws_security_group.webapp_outbound_sg.id}",
  ]

  user_data                   = "${file("./templates/userdata.sh")}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
}

resource "aws_elb" "webapp_elb" {
  name    = "ddt-webapp-elb"
  subnets = data.terraform_remote_state.networking.outputs.public_subnets

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  security_groups = ["${aws_security_group.webapp_http_inbound_sg.id}"]

  #tags = local.common_tags
}

resource "aws_autoscaling_group" "webapp_asg" {
  lifecycle {
    create_before_destroy = true
  }

  vpc_zone_identifier   = data.terraform_remote_state.networking.outputs.public_subnets
  name                  = "ddt_webapp_asg"
  max_size              = var.asg_max_size
  min_size              = var.asg_min_size
  #wait_for_elb_capacity = true
  force_delete          = true
  launch_configuration  = "${aws_launch_configuration.webapp_lc.id}"
  load_balancers        = ["${aws_elb.webapp_elb.name}"]


  tags = [
    {
      key                 = "Name"
      value               = "ddt_webapp_asg"
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = "development"
      propagate_at_launch = true
    },
    {
      key                 = "billing_code"
      value               = "342647563"
      propagate_at_launch = true
    },
    {
      key                 = "project_code"
      value               = "8675309"
      propagate_at_launch = true
    },
    {
      key                 = "network_lead"
      value               = "Mary Moe"
      propagate_at_launch = true
    },
    {
      key                 = "application_lead"
      value               = "Sally Sue"
      propagate_at_launch = true
    },
  ]

}

#
# Scale Up Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "ddt_asg_scale_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.webapp_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name                = "ddt-high-asg-cpu"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.webapp_asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scale_up.arn}"]
}

#
# Scale Down Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "ddt_asg_scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = "${aws_autoscaling_group.webapp_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name                = "ddt-low-asg-cpu"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "5"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "30"
  insufficient_data_actions = []

  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.webapp_asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scale_down.arn}"]
}


