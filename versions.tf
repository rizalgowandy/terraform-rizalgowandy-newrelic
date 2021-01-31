terraform {
  required_version = "~> 0.14.4"

  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.15.1"
    }
  }
}