variable "azure_client_id" {
  type    = string
  default = env("AZURE_CLIENT_ID")
}
variable "azure_client_secret" {
  type    = string
  default = env("AZURE_CLIENT_SECRET")
}
variable "azure_subscription_id" {
  type    = string
  default = env("AZURE_SUBSCRIPTION_ID")
}

variable "azure_region" {
  type    = string
  default = "East US"
}
