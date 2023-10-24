

resource "aws_cloudwatch_event_bus" "messenger" {
  name = "custom-bus"
}


resource "aws_cloudwatch_event_rule" "tf-rule" {
  name        = "married-rule"
  description = "trigger lambda"
  event_bus_name = aws_cloudwatch_event_bus.messenger.id

  event_pattern = <<EOF
{
  "detail": {
    "married":["true"]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "tf-lambda" {
  rule      = aws_cloudwatch_event_rule.tf-rule.name
  arn = "arn:aws:lambda:ap-south-1:721767314185:function:readEventbridge"
}


