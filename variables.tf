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

variable "base_row" {
  type    = number
  default = 1
}

variable "total_column_per_method" {
  type    = number
  default = 9
}

variable "event_name_substring" {
  type = string
}

variable "event_name_replace" {
  type = string
}