# terraform-ecs-fargate-cluster
<!-- BEGIN_TF_DOCS -->
# aws ecs fargate terraform module

### Usage

[For examples and refrences click here.](https://github.com/Rishang/terraform-aws-fargate/tree/main/examples)




## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.54.1 |

## Outputs

No outputs.

## available tfvar inputs

```hcl
# null are required inputs, 
# others are optional default values

cloudwatch_log_retention_days = 0
cluster_name                  = null
custom_log_configuration      = null
enable_container_insights     = false
enable_discovery              = false
environment                   = null
security_groups               = []
services                      = {}
subnets                       = null
use_cloudwatch_log            = false
vpc_id                        = null
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the ECS cluster | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name eg: dev, stage, prod | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnet IDs | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID | `string` | n/a | yes |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | The number of days to retain log events | `number` | `0` | no |
| <a name="input_custom_log_configuration"></a> [custom\_log\_configuration](#input\_custom\_log\_configuration) | Custom log configuration. Keep `null` if `use_cloudwatch_log` is `true` | `map(any)` | `null` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | `enabled` or `disable` container insights | `bool` | `false` | no |
| <a name="input_enable_discovery"></a> [enable\_discovery](#input\_enable\_discovery) | Enable service discovery | `bool` | `false` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A map of security groups | `list(string)` | `[]` | no |
| <a name="input_services"></a> [services](#input\_services) | A map of services to create | `map(any)` | `{}` | no |
| <a name="input_use_cloudwatch_log"></a> [use\_cloudwatch\_log](#input\_use\_cloudwatch\_log) | Enable cloudwatch log. | `bool` | `false` | no |

---
README.md created by: `terraform-docs`
<!-- END_TF_DOCS -->