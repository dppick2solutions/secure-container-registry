variable "client_id" {
  type        = string
  description = "The client id of the Entra app registration for Terraform."
}
variable "tenant_id" {
  type        = string
  description = "The Azure Tenant Id"
}
variable "local_ip" {
  type        = string
  description = "IP addresses allowed of local machine."
}