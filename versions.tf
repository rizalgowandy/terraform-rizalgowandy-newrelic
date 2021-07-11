terraform {
  required_version = "~> 1.0.2"

  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.23.0"
    }
  }
}