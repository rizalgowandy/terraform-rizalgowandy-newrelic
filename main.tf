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
      width  = 6

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `err` LIMIT 10 EXTRAPOLATE"
      }
    }

    widget_bar {
      title  = "Human error message with most occurrence"
      row    = 4
      column = 7
      width  = 6

      nrql_query {
        account_id = var.account_id
        query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' FACET `message` LIMIT 10 EXTRAPOLATE"
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
  }

  page {
    name = "Timeline"

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 1 + (widget_billboard.key * 3)
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
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 2 + (widget_billboard.key * 3)
        column = 1 + ((widget_billboard.key % 3) * 4)
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT rate(count(*), 1 minute) as 'RPM' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 3 + (widget_billboard.key * 3)
        column = 1 + ((widget_billboard.key % 3) * 4)
        width  = 1
        height = 1

        warning  = 1000
        critical = 2000

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentile(timer, 95) as ms FROM ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_line" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_line.value, var.event_method_substring, var.event_method_replace) : widget_line.value
        row    = 1 + floor(widget_line.key / 3)
        column = 2 + ((widget_line.key % 3) * 4)
        width  = 3

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) as 'Attempt', filter(count(*), WHERE metric_status IN ('success', 'expected_error')) as 'Success', filter(count(*), WHERE metric_status IN ('error')) as 'Error' from ${var.event_name} WHERE method = '${widget_line.value}' EXTRAPOLATE TIMESERIES"
        }
      }
    }
  }

  page {
    name = "Statistic"

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = "Success Rate"
        row    = 1 + (widget_billboard.key * 1)
        column = 1
        width  = 2
        height = 3

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status IN ('success', 'expected_error')) as 'Success' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = "Request per minute"
        row    = 1 + (widget_billboard.key * 1)
        column = 3
        width  = 2
        height = 3

        nrql_query {
          account_id = var.account_id
          query      = "SELECT rate(count(*), 1 minute) as 'RPM' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_line" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_line.value, var.event_method_substring, var.event_method_replace) : widget_line.value
        row    = 1 + (widget_line.key * 1)
        column = 5
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE method = '${widget_line.value}' FACET metric_status EXTRAPOLATE TIMESERIES"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 1 + (widget_billboard.key * 3)
        column = 9
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
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 1 + (widget_billboard.key * 3)
        column = 10
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status IN ('success')) as 'Real Success' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 1 + (widget_billboard.key * 3)
        column = 11
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status IN ('expected_error')) as 'Expected Error' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 1 + (widget_billboard.key * 3)
        column = 12
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status IN ('error')) as 'Error' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 2 + (widget_billboard.key * 3)
        column = 9
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) as 'Success' from ${var.event_name} WHERE method = '${widget_billboard.value}' AND metric_status IN ('success', 'expected_error')"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 2 + (widget_billboard.key * 3)
        column = 10
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) as 'Real Success' from ${var.event_name} WHERE method = '${widget_billboard.value}' AND metric_status IN ('success')"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 2 + (widget_billboard.key * 3)
        column = 11
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) as 'Expected Error' from ${var.event_name} WHERE method = '${widget_billboard.value}' AND metric_status IN ('expected_error')"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 2 + (widget_billboard.key * 3)
        column = 12
        width  = 1
        height = 1

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) as 'Error' from ${var.event_name} WHERE method = '${widget_billboard.value}' AND metric_status IN ('error')"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 3 + (widget_billboard.key * 3)
        column = 9
        width  = 1
        height = 1

        warning  = 1000
        critical = 2000

        nrql_query {
          account_id = var.account_id
          query      = "SELECT average(timer) as 'ms (avg)' FROM ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 3 + (widget_billboard.key * 3)
        column = 10
        width  = 1
        height = 1

        warning  = 1000
        critical = 2000

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentile(timer, 95) as ms FROM ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 3 + (widget_billboard.key * 3)
        column = 11
        width  = 1
        height = 1

        warning  = 1000
        critical = 2000

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentile(timer, 99) as ms FROM ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 3 + (widget_billboard.key * 3)
        column = 12
        width  = 1
        height = 1

        warning  = 1000
        critical = 2000

        nrql_query {
          account_id = var.account_id
          query      = "SELECT max(timer) as 'ms (slowest)' FROM ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }
  }

  page {
    name = "Detail"

    # 1

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 1 + (widget_billboard.key * 3)
        column = 1
        width  = 2
        height = 3

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status IN ('success', 'expected_error')) as 'Success' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 1 + (widget_billboard.key * 3)
        column = 3
        width  = 2
        height = 3

        nrql_query {
          account_id = var.account_id
          query      = "SELECT rate(count(*), 1 minute) as 'RPM' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_line" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_line.value, var.event_method_substring, var.event_method_replace) : widget_line.value
        row    = 1 + (widget_line.key * 3)
        column = 5
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) as 'Attempt', filter(count(*), WHERE metric_status IN ('success', 'expected_error')) as 'Success', filter(count(*), WHERE metric_status IN ('error')) as 'Error' from ${var.event_name} WHERE method = '${widget_line.value}' EXTRAPOLATE TIMESERIES"
        }
      }
    }


    dynamic "widget_line" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_line.value, var.event_method_substring, var.event_method_replace) : widget_line.value
        row    = 1 + (widget_line.key * 3)
        column = 9
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) as 'Attempt' from ${var.event_name} WHERE method = '${widget_line.value}' EXTRAPOLATE TIMESERIES COMPARE WITH 1 WEEK AGO"
        }
      }
    }

    # 2

    dynamic "widget_pie" {
      for_each = var.event_methods

      content {
        title  = "${var.event_method_substring != "" ? replace(widget_pie.value, var.event_method_substring, var.event_method_replace) : widget_pie.value} - Error code with most occurrence"
        row    = 2 + (widget_pie.key * 3)
        column = 1
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE method = '${widget_pie.value}' AND metric_status = 'error' FACET `code` LIMIT 10 EXTRAPOLATE"
        }
      }
    }

    dynamic "widget_bar" {
      for_each = var.event_methods

      content {
        title  = "${var.event_method_substring != "" ? replace(widget_bar.value, var.event_method_substring, var.event_method_replace) : widget_bar.value} - Error with most occurrence"
        row    = 2 + (widget_bar.key * 3)
        column = 5
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' AND method = '${widget_bar.value}' FACET `err` LIMIT 10 EXTRAPOLATE"
        }
      }
    }

    dynamic "widget_bar" {
      for_each = var.event_methods

      content {
        title  = "${var.event_method_substring != "" ? replace(widget_bar.value, var.event_method_substring, var.event_method_replace) : widget_bar.value} - Human error message with most occurrence"
        row    = 2 + (widget_bar.key * 3)
        column = 9
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' AND method = '${widget_bar.value}' FACET `message` LIMIT 10 EXTRAPOLATE"
        }
      }
    }

    # 3

    dynamic "widget_bar" {
      for_each = var.event_methods

      content {
        title  = "${var.event_method_substring != "" ? replace(widget_bar.value, var.event_method_substring, var.event_method_replace) : widget_bar.value} - Operation with most errors"
        row    = 3 + (widget_bar.key * 3)
        column = 1
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' AND method = '${widget_bar.value}' FACET `ops` LIMIT 10 EXTRAPOLATE"
        }
      }
    }

    dynamic "widget_bar" {
      for_each = var.event_methods

      content {
        title  = "${var.event_method_substring != "" ? replace(widget_bar.value, var.event_method_substring, var.event_method_replace) : widget_bar.value} - Line with most errors"
        row    = 3 + (widget_bar.key * 3)
        column = 5
        width  = 8

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status = 'error' AND method = '${widget_bar.value}' FACET `err_line` LIMIT 10 EXTRAPOLATE"
        }
      }
    }
  }

  page {
    name = "Expected Error"

    # 1

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 1 + (widget_billboard.key * 3)
        column = 1
        width  = 2
        height = 3

        nrql_query {
          account_id = var.account_id
          query      = "SELECT percentage(count(*), WHERE metric_status IN ('success')) as 'Success' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_billboard" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_billboard.value, var.event_method_substring, var.event_method_replace) : widget_billboard.value
        row    = 1 + (widget_billboard.key * 3)
        column = 3
        width  = 2
        height = 3

        nrql_query {
          account_id = var.account_id
          query      = "SELECT rate(count(*), 1 minute) as 'RPM' from ${var.event_name} WHERE method = '${widget_billboard.value}'"
        }
      }
    }

    dynamic "widget_line" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_line.value, var.event_method_substring, var.event_method_replace) : widget_line.value
        row    = 1 + (widget_line.key * 3)
        column = 5
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) as 'Attempt', filter(count(*), WHERE metric_status IN ('success')) as 'Success', filter(count(*), WHERE metric_status IN ('expected_error')) as 'Expected Error', filter(count(*), WHERE metric_status IN ('error')) as 'Error' from ${var.event_name} WHERE method = '${widget_line.value}' EXTRAPOLATE TIMESERIES"
        }
      }
    }


    dynamic "widget_line" {
      for_each = var.event_methods

      content {
        title  = var.event_method_substring != "" ? replace(widget_line.value, var.event_method_substring, var.event_method_replace) : widget_line.value
        row    = 1 + (widget_line.key * 3)
        column = 9
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) as 'Attempt' from ${var.event_name} WHERE method = '${widget_line.value}' EXTRAPOLATE TIMESERIES COMPARE WITH 1 WEEK AGO"
        }
      }
    }

    # 2

    dynamic "widget_pie" {
      for_each = var.event_methods

      content {
        title  = "${var.event_method_substring != "" ? replace(widget_pie.value, var.event_method_substring, var.event_method_replace) : widget_pie.value} - Error code with most occurrence"
        row    = 2 + (widget_pie.key * 3)
        column = 1
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE method = '${widget_pie.value}' AND metric_status IN ('error', 'expected_error') FACET `code` LIMIT 10 EXTRAPOLATE"
        }
      }
    }

    dynamic "widget_bar" {
      for_each = var.event_methods

      content {
        title  = "${var.event_method_substring != "" ? replace(widget_bar.value, var.event_method_substring, var.event_method_replace) : widget_bar.value} - Error with most occurrence"
        row    = 2 + (widget_bar.key * 3)
        column = 5
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status IN ('error', 'expected_error') AND method = '${widget_bar.value}' FACET `err` LIMIT 10 EXTRAPOLATE"
        }
      }
    }

    dynamic "widget_bar" {
      for_each = var.event_methods

      content {
        title  = "${var.event_method_substring != "" ? replace(widget_bar.value, var.event_method_substring, var.event_method_replace) : widget_bar.value} - Human error message with most occurrence"
        row    = 2 + (widget_bar.key * 3)
        column = 9
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status IN ('error', 'expected_error') AND method = '${widget_bar.value}' FACET `message` LIMIT 10 EXTRAPOLATE"
        }
      }
    }

    # 3

    dynamic "widget_bar" {
      for_each = var.event_methods

      content {
        title  = "${var.event_method_substring != "" ? replace(widget_bar.value, var.event_method_substring, var.event_method_replace) : widget_bar.value} - Operation with most errors"
        row    = 3 + (widget_bar.key * 3)
        column = 1
        width  = 4

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status IN ('error', 'expected_error') AND method = '${widget_bar.value}' FACET `ops` LIMIT 10 EXTRAPOLATE"
        }
      }
    }

    dynamic "widget_bar" {
      for_each = var.event_methods

      content {
        title  = "${var.event_method_substring != "" ? replace(widget_bar.value, var.event_method_substring, var.event_method_replace) : widget_bar.value} - Line with most errors"
        row    = 3 + (widget_bar.key * 3)
        column = 5
        width  = 8

        nrql_query {
          account_id = var.account_id
          query      = "SELECT count(*) FROM ${var.event_name} WHERE metric_status IN ('error', 'expected_error') AND method = '${widget_bar.value}' FACET `err_line` LIMIT 10 EXTRAPOLATE"
        }
      }
    }
  }
}

resource "newrelic_nrql_alert_condition" "main" {
  for_each = toset(var.event_methods)

  account_id                   = var.account_id
  policy_id                    = var.policy_id
  type                         = "static"
  name                         = "[CRITICAL] High Error Rate for ${var.event_method_substring != "" ? replace(each.key, var.event_method_substring, var.event_method_replace) : each.key}"
  description                  = "Alert when error rate is above normal condition"
  enabled                      = var.enable_alert
  violation_time_limit_seconds = 3600
  value_function               = "single_value"

  fill_option = "static"
  fill_value  = 1.0

  aggregation_window             = 60
  expiration_duration            = 120
  open_violation_on_expiration   = true
  close_violations_on_expiration = true

  nrql {
    query             = "SELECT percentage(count(*), WHERE metric_status = 'error') from ${var.event_name} WHERE method = '${each.key}'"
    evaluation_offset = 3
  }

  critical {
    operator              = "above"
    threshold             = 25
    threshold_duration    = 600
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 5
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }
}