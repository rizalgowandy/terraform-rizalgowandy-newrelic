variable "dashboard_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "application_id" {
  type = number
}

variable "account_id" {
  type = number
}

variable "event_name" {
  type = string
}

variable "event_methods" {
  type = list(string)
}

variable "event_method_substring" {
  type = string
}

variable "event_method_replace" {
  type = string
}

variable "policy_id" {
  type = number
}

variable "enable_alert" {
  type = bool
}

variable "max_width" {
  type    = number
  default = 12
}