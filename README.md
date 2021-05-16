# terraform-peractio-newrelic

Terraform module to interact with NewRelic.

### Getting Started

```hcl
data "newrelic_entity" "app_grpc" {
  # Replace with your service name.
  name   = "app_grpc"
  domain = "APM"
  type   = "APPLICATION"
}

resource "newrelic_alert_policy" "golden_signal_policy" {
  name = "Golden Signals"
}

module "grpc_dashboard" {
  source = "git::https://github.com/rizalgowandy/terraform-peractio-newrelic?ref=v0.1.0"

  # Replace with your account id.
  account_id     = var.account_id
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
  event_name           = "grpc_performance"
  # Help make widget name more feasible with replacing long method name.
  # Example:
  # "/inventory.v1.Inventory/GetProducts" => "/v1.Inventory/GetProducts"
  event_method_substring = "/inventory./"
  event_method_replace   = ""
  # Replace with your metric method name.
  event_methods        = [
    "/inventory.v1.Inventory/GetProducts",
    "/inventory.v1.Inventory/CheckStocks",
  ]
}
```

### Standardized Event Tags

- metric_status => `ENUM('success', 'error', 'expected_error')`
- method => e.g `"/inventory.v1.Inventory/GetProducts"`
- ops => e.g `"service/Inventory.GetProductDetail"`
- code => e.g `'invalid'`, and `'not_found'`
- err => the value of `error.Error()`
- err_line => e.g `"/inventory-mgmt/internal/service/inventory.go:634"`
- message => humanize error message
