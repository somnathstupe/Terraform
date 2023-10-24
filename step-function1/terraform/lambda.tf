
resource "aws_lambda_function" "lambda_function" {
  function_name    = var.lambda_function_name
  filename         = data.archive_file.lambda_zip_file.output_path
  source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
  handler          = "lambda_handler.lambda_handler"
  role             = aws_iam_role.lambda_assume_role.arn
  runtime          = "python3.8"

  lifecycle {
    create_before_destroy = true
  }
}


# Zip of lambda handler
data "archive_file" "lambda_zip_file" {
  output_path = "${path.module}/lambda_zip/lambda.zip"
  source_dir  = "${path.module}/../lambda"
  excludes    = ["__init__.py", "*.pyc"]
  type        = "zip"
}
######################################################################################
resource "aws_lambda_function" "lambda_function1" {
  function_name    = var.lambda_function_name1
  filename         = data.archive_file.lambda_zip_file1.output_path
  source_code_hash = data.archive_file.lambda_zip_file1.output_base64sha256
  handler          = "lambda_handler.lambda_handler"
  role             = aws_iam_role.lambda_assume_role1.arn
  runtime          = "python3.8"

  lifecycle {
    create_before_destroy = true
  }
}


# Zip of lambda handler
data "archive_file" "lambda_zip_file1" {
  output_path = "${path.module}/lambda_zip1/lambda1.zip"
  source_dir  = "${path.module}/../lambda1"
  excludes    = ["__init__.py", "*.pyc"]
  type        = "zip"
}





resource "aws_lambda_function" "lambda_function2" {
  function_name    = var.lambda_function_name2
  filename         = data.archive_file.lambda_zip_file2.output_path
  source_code_hash = data.archive_file.lambda_zip_file2.output_base64sha256
  handler          = "lambda_handler2.lambda_handler"
  role             = aws_iam_role.lambda_assume_role2.arn
  runtime          = "python3.8"

  lifecycle {
    create_before_destroy = true
  }
}


# Zip of lambda handler
data "archive_file" "lambda_zip_file2" {
  output_path = "${path.module}/lambda_zip2/lambda2.zip"
  source_dir  = "${path.module}/../lambda2"
  excludes    = ["__init__.py", "*.pyc"]
  type        = "zip"
}


#########################################################################################
# Lambda IAM assume role
resource "aws_iam_role" "lambda_assume_role" {
  name               = "${var.lambda_function_name}-assume-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json

  lifecycle {
    create_before_destroy = true
  }
}

# IAM policy document for lambda assume role
data "aws_iam_policy_document" "lambda_assume_role_policy_document" {
  version = "2012-10-17"

  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

##############################################################################################

# Creted role for second lambda function and assgin policy to it 

resource "aws_iam_role" "lambda_assume_role1" {
  name               = "${var.lambda_function_name1}-assume-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document1.json

  lifecycle {
    create_before_destroy = true
  }
}

# IAM policy document for lambda assume role
data "aws_iam_policy_document" "lambda_assume_role_policy_document1" {
  version = "2012-10-17"

  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
} 


##################################################################################################### 

#   Create role for third lambda function
resource "aws_iam_role" "lambda_assume_role2" {
  name               = "${var.lambda_function_name2}-assume-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document2.json

  lifecycle {
    create_before_destroy = true
  }
}

# IAM policy document for lambda assume role
data "aws_iam_policy_document" "lambda_assume_role_policy_document2" {
  version = "2012-10-17"

  statement {
    sid     = "LambdaAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

