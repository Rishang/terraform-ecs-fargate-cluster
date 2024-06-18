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

cluster_name              = null
enable_container_insights = false
services                  = {}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the ECS cluster | `string` | n/a | yes |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | `enabled` or `disable` container insights | `bool` | `false` | no |
| <a name="input_services"></a> [services](#input\_services) | A map of services to create | `map(any)` | `{}` | no |

---
README.md created by: `terraform-docs`
<!-- END_TF_DOCS -->