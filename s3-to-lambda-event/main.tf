#  eventbridge service s3 to invoke lambda function 
provider "aws" {
}

# 1. Create s3 bucket 
resource "aws_s3_bucket" "tf-bucket" {
  bucket = "s3-to-event"
}

resource "aws_s3_bucket_notification" "s3-lambda" {
  bucket = aws_s3_bucket.tf-bucket.id 
  eventbridge = true
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda.arn
    events              = ["s3:ObjectCreated:*"]
    
  }

   depends_on = [aws_lambda_permission.allow_bucket]
}

# 2.Create zip file for lambda function

provider "archive" {}

data "archive_file" "zip" {
  type="zip"
  source_file="hello_lambda.py"
  output_path ="hello_lambda.zip"

}

data "aws_iam_policy_document" "policy" {
  statement {
    sid    = ""
    effect = "Allow"

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

 # 3. Create iam role for invoke lambda 

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = "${data.aws_iam_policy_document.policy.json}"
}

# 4. Create lambda function 
resource "aws_lambda_function" "lambda" {
  function_name = "hello_lambda"
  filename = "${data.archive_file.zip.output_path}"
  source_code_hash = "${data.archive_file.zip.output_base64sha256}"

  role = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "hello_lambda.lambda_handler"
  runtime = "python3.9"
  

  environment {
    variables = {
      greeting = "Hello"
    }
}
}

# 4. assign permission to lambda function
resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.tf-bucket.arn
}

# 5. Create eventbrige rule

resource "aws_cloudwatch_event_rule" "s3-event" {
  name        = "s3-event"
  description = "Capture each AWS s3 event"

  event_pattern = <<EOF
{
  "detail-type": [
    "Object Created"
  ],
  "source": [
    "aws.s3"
  ],
  "detail": {
    "bucket": {
      "name": ["${aws_s3_bucket.tf-bucket.id}"]
    }
  }
}
EOF
 
}


# 5. set a target 
resource "aws_cloudwatch_event_target" "tf-lambda" {
  rule      = aws_cloudwatch_event_rule.s3-event.name
  arn =   aws_lambda_function.lambda.arn
}
