resource "aws_wafv2_web_acl" "main" {
  name  = "example-web-acl"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    priority = 0
    name     = "AWSManagedRulesCommonRuleSet"

    statement {
      managed_rule_group_statement {
        vendor_name = "AWS"
        name        = "AWSManagedRulesCommonRuleSet"

        # NoUserAgent_HEADER ルールを Count にオーバーライドする
        rule_action_override {
          name = "NoUserAgent_HEADER"
          action_to_use {
            count {}
          }
        }
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "example-rule-metric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "example-metric"
    sampled_requests_enabled   = true
  }
}
