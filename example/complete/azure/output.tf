output "mongodb_endpoints" {
  value       = module.mongodb.mongodb_endpoints
  description = "MongoDB endpoints in the Kubernetes cluster."
}
