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

  #####################
  # Standard widgets.
  #####################

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
    visualization = "faceted_line_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} FACET `metric_status` LIMIT 10 EXTRAPOLATE TIMESERIES"
    row           = 2
    column        = 2
  }

  widget {
    title         = "Method with most errors"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `method` LIMIT 10 EXTRAPOLATE"
    row           = 2
    column        = 3
  }

  widget {
    title         = "Operation with most errors"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `ops` LIMIT 10 EXTRAPOLATE"
    row           = 3
    column        = 1
  }

  widget {
    title         = "Error with most occurrence"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `err` LIMIT 10 EXTRAPOLATE"
    row           = 3
    column        = 2
  }

  widget {
    title         = "Error code with most occurrence"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `code` LIMIT 10 EXTRAPOLATE"
    row           = 3
    column        = 3
  }

  widget {
    title         = "Line with most errors"
    visualization = "facet_bar_chart"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `err_line` LIMIT 10 EXTRAPOLATE"
    row           = 4
    column        = 1
    width         = 2
  }

  widget {
    title         = "Human error message with most occurrence"
    visualization = "facet_table"
    nrql          = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `message` LIMIT 10 EXTRAPOLATE"
    row           = 4
    column        = 3
  }

  #####################
  # Event widgets.
  #####################

  # First rows.

  dynamic "widget" {
    for_each = var.event_methods

    content {
      title         = "${widget.value} request per minute"
      visualization = "billboard"
      nrql          = "SELECT rate(count(*), 1 minute) FROM ${var.event_name} WHERE method = '${widget.value}'"
      row           = var.base_row + widget.key * (var.total_column_per_method / 3)
      column        = 1
    }
  }

  dynamic "widget" {
    for_each = var.event_methods

    content {
      title         = "${widget.value} metric status percentage"
      visualization = "facet_pie_chart"
      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method = '${widget.value}' FACET `metric_status` LIMIT 10 EXTRAPOLATE"
      row           = var.base_row + widget.key * (var.total_column_per_method / 3)
      column        = 2
    }
  }

  dynamic "widget" {
    for_each = var.event_methods

    content {
      title         = "${widget.value} metric status histogram"
      visualization = "faceted_line_chart"
      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method = '${widget.value}' FACET `metric_status` LIMIT 10 EXTRAPOLATE TIMESERIES"
      row           = var.base_row + widget.key * (var.total_column_per_method / 3)
      column        = 3
    }
  }

  # Second rows.

  dynamic "widget" {
    for_each = var.event_methods

    content {
      title         = "${widget.value} operation with most errors"
      visualization = "facet_bar_chart"
      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method ='${widget.value}' AND metric_status = 'error' or metric_status = 'expected_error' FACET `ops` LIMIT 10 EXTRAPOLATE"
      row           = 1 + var.base_row + widget.key * (var.total_column_per_method / 3)
      column        = 1
    }
  }

  dynamic "widget" {
    for_each = var.event_methods

    content {
      title         = "${widget.value} error with most occurrence"
      visualization = "facet_bar_chart"
      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method ='${widget.value}' AND metric_status = 'error' or metric_status = 'expected_error' FACET `err` LIMIT 10 EXTRAPOLATE"
      row           = 1 + var.base_row + widget.key * (var.total_column_per_method / 3)
      column        = 2
    }
  }

  dynamic "widget" {
    for_each = var.event_methods

    content {
      title         = "${widget.value} error code with most occurrence"
      visualization = "facet_bar_chart"
      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method ='${widget.value}' AND metric_status = 'error' or metric_status = 'expected_error' FACET `code` LIMIT 10 EXTRAPOLATE"
      row           = 1 + var.base_row + widget.key * (var.total_column_per_method / 3)
      column        = 3
    }
  }

  # Third rows.

  dynamic "widget" {
    for_each = var.event_methods

    content {
      title         = "${widget.value} line with most errors"
      visualization = "facet_bar_chart"
      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method ='${widget.value}' AND metric_status = 'error' or metric_status = 'expected_error' FACET `err_line` LIMIT 10 EXTRAPOLATE"
      row           = 2 + var.base_row + widget.key * (var.total_column_per_method / 3)
      column        = 1
      width         = 2
    }
  }

  dynamic "widget" {
    for_each = var.event_methods

    content {
      title         = "${widget.value} human error message with most occurrence"
      visualization = "facet_table"
      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method ='${widget.value}' AND metric_status = 'error' or metric_status = 'expected_error' FACET `message` LIMIT 10 EXTRAPOLATE"
      row           = 2 + var.base_row + widget.key * (var.total_column_per_method / 3)
      column        = 3
    }
  }
}
