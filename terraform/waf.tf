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
      metric_name                = "example-managed-rule-metric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "ExampleRule"
    priority = 1

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          label_match_statement {
            key   = "awswaf:managed:aws:core-rule-set:NoUserAgent_Header"
            scope = "LABEL"
          }
        }

        statement {
          not_statement {
            statement {
              byte_match_statement {
                # /hello.txt 以外のパスに対して NoUserAgent_HEADER ルールを適用してブロックする
                search_string         = "/hello.txt"
                positional_constraint = "EXACTLY"

                field_to_match {
                  uri_path {}
                }

                text_transformation {
                  priority = 0
                  type     = "NONE"
                }
              }
            }
          }
        }
      }
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
