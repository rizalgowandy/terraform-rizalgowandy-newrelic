resource "newrelic_one_dashboard" "main" {
  name = var.dashboard_name

  page {
    name = "Summary"

    # 1

    widget_billboard {
      title  = "Requests per minute"
      row    = 1
      column = 1
      width  = 2

      nrql_query {
        account_id = var.account_id
        query      = "SELECT rate(count(*), 1 minute) AS 'RPM' FROM Transaction WHERE appName = '${var.service_name}'"
      }
    }

    widget_line {
      title  = "Requests per minute histogram"
      row    = 1
      column = 3
      width  = 4

      nrql_query {
        account_id = var.account_id
        query      = "SELECT rate(count(*), 1 minute) AS 'RPM' FROM Transaction WHERE appName = '${var.service_name}' TIMESERIES EXTRAPOLATE COMPARE WITH 1 week ago"
      }
    }

    widget_table {
      title  = "Requests per minute by transaction"
      row    = 1
      column = 7
      width  = 6

      nrql_query {
        account_id = var.account_id
        query      = "SELECT rate(count(*), 1 minute) FROM Transaction WHERE appName = '${var.service_name}' FACET name"
      }
    }

    # 2

    widget_billboard {
      title  = "Success rate = success + expected_error"
      row    = 2
      column = 1
      width  = 2

      nrql_query {
        account_id = var.account_id
        query      = "SELECT percentage(count(*), WHERE metric_status IN ('success', 'expected_error')) as 'Success Rate' from ${var.event_name}"
      }
    }

    widget_pie {
      title  = "Metric status percentage"
      row    = 2
      column = 3
      width  = 4

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} FACET `metric_status` LIMIT 10 EXTRAPOLATE"
      }
    }

    widget_line {
      title  = "Metric status histogram"
      row    = 2
      column = 7
      width  = 6

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} FACET `metric_status` EXTRAPOLATE TIMESERIES"
      }
    }

    # 3

    widget_billboard {
      title  = "Error count"
      row    = 3
      column = 1
      width  = 2

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) as 'Error count' from ${var.event_name} WHERE metric_status IN ('error')"
      }
    }

    widget_pie {
      title  = "Error code with most occurrence"
      row    = 3
      column = 3
      width  = 4

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `code` LIMIT 10 EXTRAPOLATE"
      }
    }

    widget_table {
      title  = "Method with most errors"
      row    = 3
      column = 7
      width  = 6

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `method` LIMIT 10 EXTRAPOLATE"
      }
    }

    # 4

    widget_bar {
      title  = "Error with most occurrence"
      row    = 4
      column = 1
      width  = 12

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `err` LIMIT 10 EXTRAPOLATE"
      }
    }

    # 5

    widget_bar {
      title  = "Operation with most errors"
      row    = 5
      column = 1
      width  = 6

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `ops` LIMIT 10 EXTRAPOLATE"
      }
    }

    widget_bar {
      title  = "Line with most errors"
      row    = 5
      column = 7
      width  = 6

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `err_line` LIMIT 10 EXTRAPOLATE"
      }
    }

    # 6

    widget_bar {
      title  = "Human error message with most occurrence"
      row    = 6
      column = 1
      width  = 12

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `message` LIMIT 10 EXTRAPOLATE"
      }
    }
  }

  page {
    name = "Timeline"

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = widget_billboard.value
        row    = var.base_row + ((widget_billboard.key - 1) * 3)
        column = 1 + ((widget_billboard.key % 3) * 4)
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status IN ('success', 'expected_error')) as 'Success' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = widget_billboard.value
        row    = 1 + var.base_row + ((widget_billboard.key - 1) * 3)
        column = 1 + ((widget_billboard.key % 3) * 4)
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT rate(count(*), 1 minute) as 'RPM' from ${var.event_name} WHERE method = '${widget_billboard.value}' AND metric_status IN ('success', 'expected_error')"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = widget_billboard.value
        row    = 2 + var.base_row + ((widget_billboard.key - 1) * 3)
        column = 1 + ((widget_billboard.key % 3) * 4)
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentile(duration, 95) * 1000 as ms from Transaction WHERE appName = '${var.service_name}' AND name = 'OtherTransaction/Go${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = widget_billboard.value
        row    = var.base_row + floor(widget_billboard.key / 3)
        column = 1 + ((widget_billboard.key % 3) * 4)
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status IN ('success', 'expected_error')) as 'Success' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_line" {
      for_each = var.event_methods

      content {
        title  = widget_line.value
        row    = var.base_row + floor(widget_line.key / 3)
        column = 2 + ((widget_line.key % 3) * 4)
        width  = 3

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) as 'Attempt', filter(count(*), WHERE metric_status IN ('success', 'expected_error')) as 'Success', filter(count(*), WHERE metric_status IN ('error')) as 'Error' from ${var.event_name} WHERE method = '${widget_line.value}' EXTRAPOLATE TIMESERIES"
        }
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
