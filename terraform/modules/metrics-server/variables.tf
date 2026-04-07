variable "chart_version" {
  type        = string
  description = "Metrics Server Helm chart version"
  default     = "3.13.0"
}

variable "replicas" {
  type        = number
  description = "Number of Metrics Server replicas"
  default     = 2
}

variable "args" {
  type        = list(string)
  description = "Extra args for Metrics Server"
  default = [
    "--kubelet-preferred-address-types=InternalIP,Hostname,ExternalIP"
  ]
}