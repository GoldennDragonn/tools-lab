variable "region" {
  description = "AWS Region"
  default     = "eu-west-1"
}

variable "ami" {
  description = "Ubuntu 20.04 AMI (x86_64)"
  default     = "ami-0136ddddd07f0584f"
}

variable "instance_type" {
  description = "Instance type"
  default     = "t3a.xlarge"
}

variable "ssh_public_key" {
  description = "SSH public key path"
  default     = "/home/yakovbe/.ssh/id_rsa.pub"
}

variable "ssh_private_key" {
  description = "SSH private key path"
  default     = "/home/yakovbe/.ssh/id_rsa"
}
