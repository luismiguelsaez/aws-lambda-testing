resource "aws_s3_bucket_object" "example" {
  bucket = aws_s3_bucket.lambda.id
  key    = "applications/example/${var.VERSION}/code.zip"
  source = "applications/example/code.zip"
  etag = filemd5("applications/example/code.zip")
}

resource "aws_lambda_function" "example" {
   function_name = "ServerlessExample"

   s3_bucket = aws_s3_bucket.lambda.id
   s3_key    = aws_s3_bucket_object.example.id

   handler = "main.handler"
   runtime = "nodejs10.x"

   role = aws_iam_role.lambda_exec.arn
}

resource "aws_iam_role" "lambda_exec" {
   name = "serverless_example_lambda"

   assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}
