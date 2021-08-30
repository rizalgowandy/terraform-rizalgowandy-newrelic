[![Release](https://img.shields.io/github/release/rizalgowandy/terraform-rizalgowandy-newrelic.svg?style=flat-square)](https://github.com/rizalgowandy/terraform-rizalgowandy-newrelic/releases)

![terraform-rizalgowandy-newrelic](https://socialify.git.ci/rizalgowandy/terraform-rizalgowandy-newrelic/image?description=1&font=Inter&logo=https%3A%2F%2Fcdn.freebiesupply.com%2Flogos%2Flarge%2F2x%2Fnew-relic-logo-png-transparent.png&pattern=Circuit%20Board&theme=Light)

## Getting Started

The idea was simple, I want to have a standardized dashboard monitoring, and alert across all services across all environments.
Hence, the automation scripts to achieve that.

## Quick Start

```terraform
data "newrelic_entity" "app_grpc" {
  # Replace with your service name.
  name   = "app_grpc"
  domain = "APM"
  type   = "APPLICATION"
}

resource "newrelic_alert_policy" "golden_signal_policy" {
  # Replace with your service name.
  name = "Golden Signals - app_grpc"
}

module "grpc_dashboard" {
  # Replace ref with the latest available version or branch.
  source = "git::https://github.com/rizalgowandy/terraform-rizalgowandy-newrelic?ref=v0.1.0"

  # Replace with your account id.
  account_id = var.account_id
  
  # Replace with your application id.
  application_id = data.newrelic_entity.app_grpc.application_id

  # Replace with your policy id.
  policy_id = newrelic_alert_policy.golden_signal_policy.id

  # Set true to enable alert.
  enable_alert = false

  # Replace with your dashboard name, should be unique for your account.
  dashboard_name = "app_grpc"
  service_name   = "app_grpc"

  # Replace with your metric name.
  event_name = "grpc_performance"

  # Help make widget name more feasible with replacing long method name.
  # Example:
  # "/inventory.v1.Inventory/GetProducts" => "/v1.Inventory/GetProducts"
  event_method_substring = "/inventory./"
  event_method_replace   = ""

  # Replace with your metric method name.
  event_methods = [
    "/inventory.v1.Inventory/GetProducts",
    "/inventory.v1.Inventory/CheckStocks",
  ]
}
```

## Standardized Event Tags

In order to have all the automation works correctly. You will need to push a specific tag for each event.

- metric_status => `ENUM('success', 'error', 'expected_error')`
- method => e.g `"/inventory.v1.Inventory/GetProducts"`
- ops => e.g `"service/Inventory.GetProductDetail"`
- code => e.g `'invalid'`, and `'not_found'`
- err => the value of `error.Error()`
- err_line => e.g `"/inventory-mgmt/internal/service/inventory.go:634"`
- message => humanize error message
