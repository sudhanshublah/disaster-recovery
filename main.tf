provider "aws" {
  region = "us-east-2"
}

provider "aws" {
  region = "us-west-1"
  alias = "california"
}

locals {
  config = tomap(jsondecode(file("./conf.json")))
}

# locals {
#   ami = lookup(map(local.config, "ami-prod"))
# }

# resource "aws_instance" "ec2" {
#   name = "something"
#   ami =  local.ami
# kcmd
# }

module "ec2prod" {
  for_each = { for t in local.config.ami-prod : t.ami => t }
  source = "./modules/ec2"
  name =  "something-${each.key}"
  ami = each.key
  instance_type = "t3a.medium"
  subnet_id = "subnet-09a3a906f53f9de29"
  tags = {
    "env" = "some"
  }

}



data "aws_db_snapshot" "db_snapshot" {
  provider = aws.california
  most_recent = true
  db_instance_identifier = "encrypted-db-test"
}

# module "rds" {
#   source = "./modules/rds/modules/db_instance"
#   identifier = var.identifier
#   instance_class    = var.instance_class
#   allocated_storage = var.allocated_storage

#   name     = var.name
#   username = var.username
#   password = var.password
#   port     = "3306"

#   iam_database_authentication_enabled = true
#   multi_az                            = var.multi_az
#   snapshot_identifier = data.aws_db_snapshot.db_snapshot.id

#   tags = var.tags
# }

# module "ec2uat" {
#   for_each = { for t in local.config.ami-uat : t.ami => t }
#   source = "./modules/ec2"
#   name =  "something"
#   ami = each.key
#   instance_type = "t3a.medium"
# }

data "aws_lb_target_group" "name" {
  # for_each = { for t in local.config.target-group : t.tg => t }
  name = "react-tg"
}

# data "aws_sns_topic" "sns" {
#   name = "Notify_MDS"
# }
# # locals {
  
# }

output "test" {
  value = module.ec2prod
}

# resource "aws_lb_target_group_attachment" "name2" {
#   for_each = { for t in local.config.ami-prod : t.ami => t }
#   target_group_arn = data.aws_lb_target_group.name.arn
#   target_id = module.ec2prod["${each.key}"].id
# }



# output "name" {
#   value = data.aws_instance.ec2.tags.Name
# }


# Creating the AWS CLoudwatch Alarm that will autoscale the AWS EC2 instance based on CPU utilization.
resource "aws_cloudwatch_metric_alarm" "EC2_CPU_Usage_70_Alarm" {
# defining the name of AWS cloudwatch alarm
  for_each = { for t in local.config.ami-prod : t.ami => t }
  alarm_name          = "significant_${var.region}_none_ec2_${module.ec2prod["${each.key}"].tags_all.Name}_cpu-utilisation_70% "
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
# Defining the metric_name according to which scaling will happen (based on CPU) 
  metric_name = "CPUUtilization"
# The namespace for the alarm's associated metric
  namespace = "AWS/EC2"
  period = "300"
  statistic = "Average"
# CPU Utilization threshold is set to 70 percent
  threshold = "70"
  # alarm_actions   = ["${data.aws_sns_topic.sns.arn}"]
  actions_enabled = true
  alarm_description     = "This metric monitors ec2 cpu utilization exceeding 70%"
  # dimensions = {
  #   InstanceId = each.key
  # }
  dimensions = {
    InstanceId = module.ec2prod["${each.key}"].id
  }

  # depends_on = [
  #   data.aws_instances.my_instances
  # ]

}

# Creating the AWS CLoudwatch Alarm that will autoscale the AWS EC2 instance based on CPU utilization.
resource "aws_cloudwatch_metric_alarm" "EC2_CPU_Usage_60_Alarm" {
# defining the name of AWS cloudwatch alarm
  for_each = { for t in local.config.ami-prod : t.ami => t }
  alarm_name          = "moderate_${var.region}_none_ec2_${module.ec2prod["${each.key}"].tags_all.Name}_cpu-utilisation_60%"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
# Defining the metric_name according to which scaling will happen (based on CPU) 
  metric_name = "CPUUtilization"
# The namespace for the alarm's associated metric
  namespace = "AWS/EC2"
# After AWS Cloudwatch Alarm is triggered, it will wait for 60 seconds and then autoscales
  period = "300"
  statistic = "Average"
# CPU Utilization threshold is set to 10 percent
  threshold = "60"
  # alarm_actions   = ["${data.aws_sns_topic.sns.arn}"]
  actions_enabled = true
  alarm_description     = "This metric monitors ec2 cpu utilization exceeding 60%"
  # dimensions = {
  #   InstanceId = each.key
  # }
  dimensions = {
    InstanceId = module.ec2prod["${each.key}"].id
  }

  # depends_on = [
  #   data.aws_instances.my_instances
  # ]

}

# Creating the AWS CLoudwatch Alarm that will autoscale the AWS EC2 instance based on CPU utilization.
resource "aws_cloudwatch_metric_alarm" "EC2_CPU_Usage_90_Alarm" {
# defining the name of AWS cloudwatch alarm
  for_each = { for t in local.config.ami-prod : t.ami => t }
  alarm_name          = "critical_${var.region}_none_ec2_${module.ec2prod["${each.key}"].tags_all.Name}_cpu-utilisation_90% "
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
# Defining the metric_name according to which scaling will happen (based on CPU) 
  metric_name = "CPUUtilization"
# The namespace for the alarm's associated metric
  namespace = "AWS/EC2"
# After AWS Cloudwatch Alarm is triggered, it will wait for 60 seconds and then autoscales
  period = "300"
  statistic = "Average"
# CPU Utilization threshold is set to 10 percent
  threshold = "90"
  # alarm_actions   = ["${data.aws_sns_topic.sns.arn}"]
  actions_enabled = true
  alarm_description     = "This metric monitors ec2 cpu utilization exceeding 90%"
  dimensions = {
    InstanceId = module.ec2prod["${each.key}"].id
  }

  # depends_on = [
  #   data.aws_instances.my_instances
  # ]

}

resource "aws_cloudwatch_metric_alarm" "instance-health-check" {
  for_each = { for t in local.config.ami-prod : t.ami => t }
  alarm_name                = "critical_${module.ec2prod["${each.key}"].tags_all.Name}-StatusCheckFailed_System"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ec2 health status"
  # alarm_actions             = ["${data.aws_sns_topic.sns.arn}"]
  dimensions = {
    InstanceId = module.ec2prod["${each.key}"].id
  }
}
