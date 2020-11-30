resource "aws_api_gateway_rest_api" "main" {
  name = format("%s-main", var.environment)

  endpoint_configuration {
    # EDGE endpoint type for internet access from different countries or regions
    types = ["EDGE"]
  }
}

resource "aws_api_gateway_resource" "application" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "application"
}

resource "aws_api_gateway_method" "application_get" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.application.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "application" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.application.id
  http_method = aws_api_gateway_method.application_get.http_method
  # When backend application is a lambda function, integration_http_method must be POST
  # https://github.com/amazon-archives/aws-apigateway-importer/issues/9#issuecomment-129651005
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example.invoke_arn
}

resource "aws_api_gateway_deployment" "example" {
   depends_on = [
     aws_api_gateway_integration.application
   ]

   rest_api_id = aws_api_gateway_rest_api.main.id
   stage_name  = "test"
}

# Create lambda function permissions
resource "aws_lambda_permission" "example" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  #source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.main.id}/*/${aws_api_gateway_method.application_get.http_method}${aws_api_gateway_resource.application.path}"
}
