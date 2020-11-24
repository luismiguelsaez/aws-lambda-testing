resource "aws_s3_bucket" "lambda" {
  bucket = "luismiguelsaez-lambda-functions-testing"
  acl    = "private"
}