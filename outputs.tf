output "dashboard_url" {
  value       = newrelic_one_dashboard.main.permalink
  description = "The created dashboard url"
}
