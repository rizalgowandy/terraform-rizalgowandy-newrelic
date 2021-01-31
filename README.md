# terraform-peractio-newrelic

Terraform module to interact with NewRelic.

### Getting Started

```hcl
data "newrelic_entity" "app_grpc" {
  name   = "app_grpc"
  # Replace with your service name.
  domain = "APM"
  type   = "APPLICATION"
}

module "grpc_dashboard" {
  source = "git::https://github.com/rizalgowandy/terraform-peractio-newrelic?ref=v0.0.2"

  # Replace with your service name.
  service_name   = "app_grpc"

  # Replace with your application id.
  application_id = data.newrelic_entity.app_grpc.application_id

   # Replace with your metric name.
  event_name     = "grpc_performance"

   # Replace with your metric method name.
  event_methods  = [
    "/inventory.v1.Inventory/GetProducts",
    "/inventory.v1.Inventory/CheckStocks",
  ]
}
```

### Required Event Tags

- metric_status
- method
- ops
- code
- err
- err_line
- message
