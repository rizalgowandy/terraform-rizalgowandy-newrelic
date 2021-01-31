terraform {
  required_version = "~> 0.14.5"

  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "2.16.0"
    }
  }
}