#########################################################################
# Cloudwatch trigger
#########################################################################

resource "aws_cloudwatch_event_rule" "this" {
  name                = "${var.resource_name_prefix}-populate-nlb-tg-with-address-from-dns"
  description         = "Populate NLB Target Group with IP"
  schedule_expression = var.schedule_expression
  depends_on = [
    aws_lambda_function.this
  ]
}

resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = aws_lambda_function.this.arn
}

#########################################################################
# Lambda IAM
#########################################################################

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

data "aws_iam_policy_document" "policy" {

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
    effect = "Allow"
    sid    = "LambdaLogging"
  }

  statement {
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets"
    ]
    resources = [var.nlb_tg_arn]
    effect    = "Allow"
    sid       = "ChangeTargetGroups"
  }

  statement {
    actions = [
      "elasticloadbalancing:DescribeTargetHealth"
    ]
    resources = ["*"]
    effect    = "Allow"
    sid       = "DescribeTargetGroups"
  }

  statement {
    actions = [
      "cloudwatch:putMetricData"
    ]
    resources = ["*"]
    effect    = "Allow"
    sid       = "CloudWatch"
  }
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.resource_name_prefix}-populate-nlb-tg-with-address-from-dns"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.policy.json
}

#########################################################################
# Lambda
#########################################################################

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/package"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "this" {
  filename         = data.archive_file.this.output_path
  function_name    = "${var.resource_name_prefix}-populate-nlb-tg-with-address-from-dns"
  role             = aws_iam_role.this.arn
  handler          = "populate_nlb_tg_with_address_from_dns.handler"
  source_code_hash = data.archive_file.this.output_base64sha256
  runtime          = "python3.8"
  memory_size      = 128
  timeout          = 300

  environment {
    variables = {
      SERVICE_HOSTNAME          = element(split(":", var.service_hostname), 0)
      NLB_TG_ARN                = var.nlb_tg_arn
      MAX_LOOKUP_PER_INVOCATION = var.max_lookup_per_invocation
    }
  }
}


