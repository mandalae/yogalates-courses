provider "aws" {
  region = "eu-west-1"
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
