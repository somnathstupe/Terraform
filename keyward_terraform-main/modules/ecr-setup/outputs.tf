output "registry_id" {
  value       = aws_ecr_repository.model_repository.registry_id
  description = "Registry ID"
}
output "registry_url" {
  value       = aws_ecr_repository.model_repository.repository_url
  description = "Repository URL"
}

# output "repository_name" {
#   value       = aws_ecr_repository.model_repository.repository_name
#   description = "Registry name"
# }