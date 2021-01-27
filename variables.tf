variable "service_name" {
  type = string
}

variable "application_id" {
  type = number
}

variable "events" {
  type = list(
    object({
      name = string
      methods = list(
        object({
          method = string
        })
      )
    })
  )
}
