variable "service_name" {
  type = string
}

variable "application_id" {
  type = number
}

variable "event_name" {
  type = string
}

variable "event_methods" {
  type = map(string)
}

variable "base_row" {
  type    = number
  default = 5
}

variable "total_column_per_method" {
  type    = number
  default = 9
}