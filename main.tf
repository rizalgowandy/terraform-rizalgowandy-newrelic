resource "newrelic_one_dashboard" "main" {
  name = var.dashboard_name

  page {
    name        = "Success Rate"
    description = "Rate => metric_status = success + expected_error"

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = widget_billboard.value
        row    = var.base_row + floor(widget_billboard.key / 3)
        column = 1 + ((widget_billboard.key % 3) * 4)
        width  = 4

        warning  = 95
        critical = 75

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status IN ('success', 'expected_error')) as 'Success Rate' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }
  }

  page {
    name        = "Error Rate"
    description = "Rate => metric_status = error"

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = widget_billboard.value
        row    = var.base_row + floor(widget_billboard.key / 3)
        column = 1 + ((widget_billboard.key % 3) * 4)
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status = 'error') as 'Error Rate' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }
  }

  page {
    name        = "Real Error Rate"
    description = "Rate => metric_status = error + expected_error"

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = widget_billboard.value
        row    = var.base_row + floor(widget_billboard.key / 3)
        column = 1 + ((widget_billboard.key % 3) * 4)
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status IN ('error', 'expected_error')) as 'Real Error Rate' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }
  }

  page {
    name = "Summary"

    widget_billboard {
      title  = "Requests per minute"
      row    = 1
      column = 1

      nrql_query {
        account_id = var.account_id
        query      = "SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName = '${var.service_name}'"
      }
    }

    widget_table {
      title  = "Requests per minute, by transaction"
      row    = 1
      column = 5
      width  = 8

      nrql_query {
        account_id = var.account_id
        query      = "SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName = '${var.service_name}' FACET name"
      }
    }

    widget_billboard {
      title  = "Success rate"
      row    = 2
      column = 1

      warning  = 95
      critical = 75

      nrql_query {
        account_id = var.account_id
        query      = "SELECT percentage(count(*), WHERE metric_status IN ('error', 'expected_error')) as 'Success Rate' from ${var.event_name}"
      }
    }

    widget_pie {
      title  = "Metric status percentage"
      row    = 2
      column = 5

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} FACET `metric_status` LIMIT 10 EXTRAPOLATE"
      }
    }

    widget_line {
      title  = "Metric status histogram"
      row    = 2
      column = 9

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} FACET `metric_status` LIMIT 10 EXTRAPOLATE TIMESERIES"
      }
    }

    widget_table {
      title  = "Method with most errors"
      row    = 3
      column = 1
      width  = 6

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `method` LIMIT 10 EXTRAPOLATE"
      }
    }

    widget_table {
      title  = "Human error message with most occurrence"
      row    = 3
      column = 7
      width  = 6

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `message` LIMIT 10 EXTRAPOLATE"
      }
    }

    widget_bar {
      title  = "Error with most occurrence"
      row    = 4
      column = 1

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `err` LIMIT 10 EXTRAPOLATE"
      }
    }

    widget_bar {
      title  = "Error code with most occurrence"
      row    = 4
      column = 5

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `code` LIMIT 10 EXTRAPOLATE"
      }
    }

    widget_bar {
      title  = "Operation with most errors"
      row    = 4
      column = 9

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `ops` LIMIT 10 EXTRAPOLATE"
      }
    }

    widget_table {
      title  = "Line with most errors"
      row    = 5
      column = 1
      width  = 12

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' or metric_status = 'expected_error' FACET `err_line` LIMIT 10 EXTRAPOLATE"
      }
    }
  }

  #  page {
  #    name = "Detail"
  #  }
}

#resource "newrelic_dashboard" "main" {
#  title = var.dashboard_name
#
#  #####################
#  # Event widgets.
#  #####################
#
#  # First rows.
#
#  dynamic "widget" {
#    for_each = var.event_methods
#
#    content {
#      title         = "${widget.value} request per minute"
#      visualization = "billboard"
#      nrql          = "SELECT rate(count(*), 1 minute) FROM ${var.event_name} WHERE method = '${widget.value}'"
#      row           = var.base_row + widget.key * (var.total_column_per_method / 3)
#      column        = 1
#    }
#  }
#
#  dynamic "widget" {
#    for_each = var.event_methods
#
#    content {
#      title         = "${widget.value} metric status percentage"
#      visualization = "facet_pie_chart"
#      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method = '${widget.value}' FACET `metric_status` LIMIT 10 EXTRAPOLATE"
#      row           = var.base_row + widget.key * (var.total_column_per_method / 3)
#      column        = 2
#    }
#  }
#
#  dynamic "widget" {
#    for_each = var.event_methods
#
#    content {
#      title         = "${widget.value} metric status histogram"
#      visualization = "faceted_line_chart"
#      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method = '${widget.value}' FACET `metric_status` LIMIT 10 EXTRAPOLATE TIMESERIES"
#      row           = var.base_row + widget.key * (var.total_column_per_method / 3)
#      column        = 3
#    }
#  }
#
#  # Second rows.
#
#  dynamic "widget" {
#    for_each = var.event_methods
#
#    content {
#      title         = "${widget.value} error with most occurrence"
#      visualization = "facet_bar_chart"
#      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method ='${widget.value}' AND metric_status = 'error' or metric_status = 'expected_error' FACET `err` LIMIT 10 EXTRAPOLATE"
#      row           = 1 + var.base_row + widget.key * (var.total_column_per_method / 3)
#      column        = 1
#    }
#  }
#
#  dynamic "widget" {
#    for_each = var.event_methods
#
#    content {
#      title         = "${widget.value} error code with most occurrence"
#      visualization = "facet_bar_chart"
#      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method ='${widget.value}' AND metric_status = 'error' or metric_status = 'expected_error' FACET `code` LIMIT 10 EXTRAPOLATE"
#      row           = 1 + var.base_row + widget.key * (var.total_column_per_method / 3)
#      column        = 2
#    }
#  }
#
#  dynamic "widget" {
#    for_each = var.event_methods
#
#    content {
#      title         = "${widget.value} human error message with most occurrence"
#      visualization = "facet_table"
#      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method ='${widget.value}' AND metric_status = 'error' or metric_status = 'expected_error' FACET `message` LIMIT 10 EXTRAPOLATE"
#      row           = 1 + var.base_row + widget.key * (var.total_column_per_method / 3)
#      column        = 3
#    }
#  }
#
#  # Third rows.
#
#  dynamic "widget" {
#    for_each = var.event_methods
#
#    content {
#      title         = "${widget.value} operation with most errors"
#      visualization = "facet_bar_chart"
#      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method ='${widget.value}' AND metric_status = 'error' or metric_status = 'expected_error' FACET `ops` LIMIT 10 EXTRAPOLATE"
#      row           = 2 + var.base_row + widget.key * (var.total_column_per_method / 3)
#      column        = 1
#    }
#  }
#
#  dynamic "widget" {
#    for_each = var.event_methods
#
#    content {
#      title         = "${widget.value} line with most errors"
#      visualization = "facet_bar_chart"
#      nrql          = "SELECT count(*) FROM ${var.event_name} WHERE method ='${widget.value}' AND metric_status = 'error' or metric_status = 'expected_error' FACET `err_line` LIMIT 10 EXTRAPOLATE"
#      row           = 2 + var.base_row + widget.key * (var.total_column_per_method / 3)
#      column        = 2
#      width         = 2
#    }
#  }
#}
