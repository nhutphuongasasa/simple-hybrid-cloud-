variable "project_id" {
  type        = string
  description = "ID của dự án trên Google Cloud Platform"
}

variable "region" {
  type        = string
  description = "Vùng trên Google Cloud Platform"
}

variable "zone" {
  type        = string
  description = "Vùng con trên Google Cloud Platform"
}

variable "vpn_shared_secret" {
  description = "Shared secret IPsec — phải giống với pfSense"
  type        = string
  sensitive   = true
}