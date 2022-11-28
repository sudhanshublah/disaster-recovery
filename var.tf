variable "identifier" {}
variable "allocated_storage" {}
variable "engine" {}
variable "engine_version" {}
variable "instance_class" {}
variable "name" {}
variable "username" {}
variable "password" {}
variable "multi_az" {}
variable "tags" {}
variable "family" {}
variable "deletion_protection" {}
variable "subnet_ids" {}
variable "major_engine_version" {}
variable "sgname" {
  type = string
}
variable "sgdescription" {
  type = string
}
variable "sgtags" {
  type = map(string)
}
variable "bucket_name" {}
variable "key" {}
variable "s3bucket_region" {}



variable "region" {}