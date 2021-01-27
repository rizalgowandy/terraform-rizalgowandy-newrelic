resource "newrelic_dashboard" "main" {
  title = var.service_name

  filter {
    event_types = [
      "Transaction"
    ]
    attributes = [
      "appName",
      "name",
      "metric_status",
      "method",
      "ops",
      "code",
      "err",
      "err_line",
      "message",
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
    title         = "Requests per minute, by transaction"
    visualization = "facet_table"
    nrql          = "SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName ='${var.service_name}' FACET name"
    row           = 1
    column        = 2
    width         = 2
  }

  widget {
    title         = "Metric status percentage"
    visualization = "facet_pie_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} FACET `metric_status` LIMIT 10 EXTRAPOLATE"
    row           = 2
    column        = 1
  }

  widget {
    title         = "Metric status histogram"
    visualization = "faceted_area_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} FACET `metric_status` LIMIT 10 EXTRAPOLATE TIMESERIES"
    row           = 2
    column        = 2
  }

  widget {
    title         = "Method with most errors"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `method` LIMIT 10 EXTRAPOLATE"
    row           = 2
    column        = 3
  }

  widget {
    title         = "Operation with most errors"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `ops` LIMIT 10 EXTRAPOLATE"
    row           = 3
    column        = 1
  }

  widget {
    title         = "Error with most occurrence"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `err` LIMIT 10 EXTRAPOLATE"
    row           = 3
    column        = 2
  }

  widget {
    title         = "Error code with most occurrence"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `code` LIMIT 10 EXTRAPOLATE"
    row           = 3
    column        = 3
  }

  widget {
    title         = "Line with most errors"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `err_line` LIMIT 10 EXTRAPOLATE"
    row           = 4
    column        = 1
    width         = 2
  }

  widget {
    title         = "Human error message with most occurrence"
    visualization = "facet_table"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `message` LIMIT 10 EXTRAPOLATE"
    row           = 4
    column        = 3
  }

  widget {
    title         = "Human error message with most occurrence"
    visualization = "facet_table"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `message` LIMIT 10 EXTRAPOLATE"
    row           = 4
    column        = 3
  }
}