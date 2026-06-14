#create S3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "damodar-june-8.6.26"
  lifecycle {
    ignore_changes = [bucket]
  }
}

#upload local file to S3 bucket local file path: C:\Users\ADMIN\Desktop\Terraform-practice\terraform9am\day-7-lambda-s3-upload-app\lambda_function.zip
resource "aws_s3_object" "my_object" {
  bucket = aws_s3_bucket.my_bucket.id
  key    = "lambda_function.zip"
  source = "C:/Users/ADMIN/Desktop/Terraform-practice/terraform9am/day-7-lambda-s3-upload-app/lambda_function.zip"
}
#create a role for lambda function and attach policy to it
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
#attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
#create lambda function and take lambda_function.zip file from S3 bucket
resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  s3_bucket = aws_s3_bucket.my_bucket.id
  s3_key    = aws_s3_object.my_object.key
}
#add schedule to lambda function to run for every 5 minutes using event bridge rule
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "lambda_schedule"
  schedule_expression = "rate(5 minutes)"
}
#add target to event bridge rule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "my_lambda_target"
  arn       = aws_lambda_function.my_lambda.arn
}
#add permission to lambda function to allow event bridge to invoke it
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}
