# docker build -t get_price_forecast_apigw .
# aws ecr get-login-password --region us-east-1
# docker login --username AWS --password ... <accountId>.dkr.ecr.us-east-1.amazonaws.com
# docker tag get_price_forecast_apigw:latest <accountId>.dkr.ecr.us-east-1.amazonaws.com/get_price_forecast_apigw:latest
# docker push <accountId>.dkr.ecr.us-east-1.amazonaws.com/get_price_forecast_apigw:latest

terraform {
  backend "s3" {
    bucket = "sod-auctions-deployments"
    key    = "terraform/get_price_forecast_apigw"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "app_name" {
  type    = string
  default = "get_price_forecast_apigw"
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.app_name}_execution_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "get_price_forecast_apigw" {
  function_name = var.app_name
  description   = "2"
  memory_size   = 1024
  role          = aws_iam_role.lambda_exec.arn
  image_uri     = "153163178336.dkr.ecr.us-east-1.amazonaws.com/get_price_forecast_apigw:latest"
  package_type  = "Image"
  timeout       = 60
}