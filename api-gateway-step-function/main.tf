
#  Create a API Gateway
resource "aws_api_gateway_rest_api" "tf-api" {
  name = "myapi"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "resource"
  parent_id   = aws_api_gateway_rest_api.tf-api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.tf-api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.tf-api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.tf-api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:states:action/StartExecution"  
    request_templates = {
        "application/json" = <<EOF
   
   {
        "input": "$util.escapeJavaScript($input.json('$'))",
        "stateMachineArn": "arn:aws:states:ap-south-1:721767314185:execution:test_step_function1:2f18c4b8-eb8f-0010-fe58-87ea33047b5d"
        
    }
    EOF
    }

}

# resource "aws_api_gateway_deployment" "step-api-gateway-deployment" {
#   rest_api_id = "${aws_api_gateway_rest_api.api.id}"
#   stage_name  = "dev"
# }

# output "url" {
#   value = "${aws_api_gateway_deployment.step-api-gateway-deployment.invoke_url}/startStepFunctions"
# }
