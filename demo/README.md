# Demo Terraform Application

This demo deploys [`comicchat`](https://github.com/gyng/comicchat) behind an Elastic Load balancer
using [Terraform](https://www.terraform.io/).

__DIAGRAM OF INFRASTRUCTURE__ Cloudcraft

## Usage

You should familiarise yourself with the
[basics](https://www.terraform.io/intro/getting-started/install.html) of Terraform before
continuing.

There are some required [input](https://www.terraform.io/intro/getting-started/variables.html)
variables that you will need to provide.

Once that is done, you can simply run

```bash
terraform init

terraform plan

terraform apply
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| app_branch | Git branch to checkout the app source code from | string | `master` | no |
| app_src_url | Git URL to checkout the app source code from | string | `https://github.com/gyng/comicchat.git` | no |
| aws_region | Region to deploy to | string | `ap-southeast-1` | no |
| client_asg_name | Name of the Autoscaling group for clients | string | `commicchat-client` | no |
| client_certificate_arn | ARN of the certificate in ACM to use for the Client domain | string | - | yes |
| client_domain | Domain for Client | string | - | yes |
| client_route53_zone | Route53 Zone Name to create the Client DNS record in | string | - | yes |
| client_size | Number of client instances to launch | string | `3` | no |
| instance_type | Type of instance to launch | string | `t2.micro` | no |
| lb_name | Name of the load balancer to create | string | `comicchat` | no |
| server_asg_name | Name of the Autoscaling group for server | string | `commicchat-server` | no |
| server_certificate_arn | ARN of the certificate in ACM to use for the Server domain | string | - | yes |
| server_domain | Domain for the server | string | - | yes |
| server_route53_zone | Route53 Zone name to create the Server DNS record in | string | - | yes |
| ssh_cidr | CIDR to allow SSH access from | string | `<list>` | no |
| ssh_key | Name of the SSH key to allow for SSH access | string | `` | no |
| subnet_ids | A list of subnet IDs to launch instances in. | list | - | yes |
| tags | Tags to add to all resources that support tags | string | `<map>` | no |
| vpc_id | VPC ID to launch resources in | string | - | yes |
