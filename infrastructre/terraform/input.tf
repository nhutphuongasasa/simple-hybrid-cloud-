variable "instance_name" { 
    type = string
    default = "my-vm-instance" 
}

variable "instance_name_frontend" { 
    type = string
    default = "my-vm-instance-frontend" 
}

variable "instance_name_backend" { 
    type = string
    default = "my-vm-instance-backend" 
}

variable "machine_type"  { 
    type = string
    default = "e2-small" 
}

variable "tags" {
  type    = list(string)
  default = ["web-server", "allow-ssh"]
}

variable "min_replicas"  { 
    type = number
     default = 1 
}

variable "max_replicas"  { 
    type = number 
    default = 5 
}

variable "cpu_target"    {
     type = number
      default = 0.6
}