provider "aws" {
  region = "eu-west-1"
}

variable "aws_account" {
  type = string
  default = "368263227121"
}

resource "aws_api_gateway_rest_api" "Yogalates" {
  name = "Yogalates"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "courses" {
  rest_api_id = aws_api_gateway_rest_api.Yogalates.id
  parent_id   = aws_api_gateway_rest_api.Yogalates.root_resource_id
  path_part   = "courses"
}

resource "aws_api_gateway_method" "coursesGET" {
  rest_api_id   = aws_api_gateway_rest_api.Yogalates.id
  resource_id   = aws_api_gateway_resource.courses.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "coursesIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.Yogalates.id
  resource_id             = aws_api_gateway_resource.courses.id
  http_method             = aws_api_gateway_method.coursesGET.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.Yogalates-courses.invoke_arn
}

resource "aws_lambda_permission" "courses_apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${aws.region}:${var.aws_account}:${aws_api_gateway_rest_api.Yogalates.id}/*/${aws_api_gateway_method.coursesGET.http_method}${aws_api_gateway_resource.courses.path}"
}

resource "aws_lambda_permission" "Yogalates-courses" {
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.Yogalates-courses.function_name}"
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_function" "Yogalates-courses" {
  filename      = "../artifact/artifact.zip"
  function_name = "Yogalates-courses"
  role          = "arn:aws:iam::${var.aws_account}:role/BasicLambdaRole"
  handler       = "index.handler"
  source_code_hash = "${filebase64sha256("../artifact/artifact.zip")}"
  runtime       = "nodejs12.x"
}
