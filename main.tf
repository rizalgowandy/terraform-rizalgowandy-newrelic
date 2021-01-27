resource "newrelic_dashboard" "main" {
  title = var.service_name

  filter {
    event_types = [
      "Transaction"
    ]
    attributes = [
      "appName",
      "name",
      # custom service attribute
      "metric_status",
      "method",
      "ops",
      "err",
      "err_line",
    ]
  }

  widget {
    title         = "Requests per minute"
    visualization = "billboard"
    nrql          = "SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName ='${var.service_name}'"
    row           = 1
    column        = 1
  }

  widget {
    title         = "Error rate"
    visualization = "gauge"
    nrql          = "SELECT percentage(count(*), WHERE error IS True) FROM Transaction WHERE appName ='${var.service_name}'"
    threshold_red = 2.5
    row           = 1
    column        = 2
  }

  widget {
    title         = "Average transaction duration, by application"
    visualization = "facet_bar_chart"
    nrql          = "SELECT average(duration) FROM Transaction WHERE appName ='${var.service_name}' FACET appName"
    row           = 1
    column        = 3
  }

  widget {
    title         = "Apdex, top 5 by host"
    duration      = 1800000
    visualization = "metric_line_chart"
    entity_ids = [
      var.application_id,
    ]
    metric {
      name = "Apdex"
      values = [
      "score"]
    }
    facet    = "host"
    limit    = 5
    order_by = "score"
    row      = 2
    column   = 1
  }

  widget {
    title         = "Requests per minute, by transaction"
    visualization = "facet_table"
    nrql          = "SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName ='${var.service_name}' FACET name"
    row           = 2
    column        = 2
    width         = 2
  }

  widget {
    title         = "Metric status percentage"
    visualization = "facet_pie_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} FACET `metric_status` LIMIT 10 EXTRAPOLATE"
    row           = 3
    column        = 1
  }


  widget {
    title         = "Metric status percentage"
    visualization = "facet_pie_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} FACET `metric_status` LIMIT 10 EXTRAPOLATE"
    row           = 3
    column        = 1
  }

  widget {
    title         = "Metric status histogram"
    visualization = "faceted_area_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} FACET `metric_status` LIMIT 10 EXTRAPOLATE TIMESERIES"
    row           = 3
    column        = 2
  }

  widget {
    title         = "Host"
    visualization = "facet_table"
    nrql          = "SELECT count(*) FROM ${var.event_name} FACET `host` LIMIT 10 EXTRAPOLATE"
    row           = 3
    column        = 3
  }

  widget {
    title         = "Method count"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} FACET `method` LIMIT 10 EXTRAPOLATE"
    row           = 4
    column        = 1
    width         = 3
  }

  widget {
    title         = "Method with most errors"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `method` LIMIT 10 EXTRAPOLATE"
    row           = 5
    column        = 1
  }

  widget {
    title         = "Operation with most errors"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `ops` LIMIT 10 EXTRAPOLATE"
    row           = 5
    column        = 2
  }

  widget {
    title         = "Error with most occurrence"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `err` LIMIT 10 EXTRAPOLATE"
    row           = 5
    column        = 3
  }

  widget {
    title         = "Line with most errors"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `err_line` LIMIT 10 EXTRAPOLATE"
    row           = 6
    column        = 1
    width         = 2
  }

  widget {
    title         = "Hostname with most errors"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `hostname` LIMIT 10 EXTRAPOLATE"
    row           = 6
    column        = 1
    width         = 2
  }
}

//SELECT count(*) FROM ${var.event_name} WHERE method = '/subscription.v1.Subscription/GetDigitalSubscriptions' FACET `metric_status` LIMIT 10 EXTRAPOLATE
//SELECT count(*) FROM ${var.event_name} WHERE method = '/subscription.v1.Subscription/GetDigitalSubscriptions' FACET `metric_status` LIMIT 10 EXTRAPOLATE TIMESERIES
//SELECT count(*) FROM ${var.event_name} WHERE method = '/subscription.v1.Subscription/GetDigitalSubscriptions' AND metric_status = 'error' FACET `ops` LIMIT 10 EXTRAPOLATE
//SELECT count(*) FROM ${var.event_name} WHERE method = '/subscription.v1.Subscription/GetDigitalSubscriptions' AND metric_status = 'error' FACET `err` LIMIT 10 EXTRAPOLATE
//SELECT count(*) FROM ${var.event_name} WHERE method = '/subscription.v1.Subscription/GetDigitalSubscriptions' AND metric_status = 'error' FACET `err_line` LIMIT 10 EXTRAPOLATE
