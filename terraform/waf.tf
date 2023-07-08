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
            # ラベルは公式ドキュメントに記載されている
            # https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/aws-managed-rule-groups-baseline.html
            key   = "awswaf:managed:aws:core-rule-set:NoUserAgent_Header"
            scope = "LABEL"
          }
        }

        # 特定のパス以外に対して NoUserAgent_HEADER ルールを適用してブロックする
        dynamic "statement" {
          for_each = ["/hello.txt"] # ブロックするパスのリスト

          content {
            not_statement {
              statement {
                byte_match_statement {
                  search_string         = statement.value
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
