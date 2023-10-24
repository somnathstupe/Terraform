# output "aws_sagemaker_notebook_url" {
#     value = aws_sagemaker_notebook_instance.ni.url
# }

output "sagemaker_notebook_instance_id" {
  description = "The name of the notebook instance."
  value       = element(concat(aws_sagemaker_notebook_instance.ni.*.id, [""]), 0)
}