
provider "aws" {
  
}

resource "aws_sfn_state_machine" "sfn-state-machine" {

  name = "tf-step-function"
  role_arn = "arn:aws:iam::721767314185:role/step-function-execute"

  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "ProcessTransaction",
  "States": {
    "ProcessTransaction": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.TransactionType",
          "StringEquals": "PURCHASE",
          "Next": "ProcessPurchase"
        },
        {
          "Variable": "$.TransactionType",
          "StringEquals": "REFUND",
          "Next": "ProcessRefund"
        }
      ]
    },
    "ProcessPurchase": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-south-1:721767314185:function:purchase-function",
      "End": true
    },
    "ProcessRefund": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:ap-south-1:721767314185:function:refund-function",
      "End": true
    }
  }
}
EOF
}
