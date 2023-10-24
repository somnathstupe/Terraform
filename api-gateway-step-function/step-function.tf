resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "test-step-function1"
  role_arn = aws_iam_role.iam_for_sfn.arn

   definition = <<EOF
{
  "Comment": "Invoke AWS Lambda from AWS Step Functions with Terraform",
  "StartAt": "HelloWorld",
  "States": {
    "HelloWorld": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-south-1:721767314185:function:test_lambda",
      "Next": "SecondLambda"
    },
    "SecondLambda": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-south-1:721767314185:function:test_lambda1",
      "Next": "ThirdLambda"
    },
    "ThirdLambda": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-south-1:721767314185:function:test_lambda2",
      "End": true
    }
  }
} 
EOF

}



resource "aws_iam_role" "iam_for_sfn" {
  name               = "${var.step_function_name}-role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "states.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": "StepFunctionAssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy" "step_function_policy" {
  name    = "${var.step_function_name}-policy"
  role    = aws_iam_role.iam_for_sfn.id

  policy  = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:lambda:ap-south-1:721767314185:function:test_lambda"
      },
      
       {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "arn:aws:lambda:ap-south-1:721767314185:function:test_lambda1"
      },
      {
        "Action": [
          "lambda:InvokeFunction"
        ],
        "Effect": "Allow",
        "Resource": "$arn:aws:lambda:ap-south-1:721767314185:function:test_lambda2"
      }
    ]
  }
  EOF
}


