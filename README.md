# aws-lambda-testing

### Deploy

```
export TF_VAR_VERSION=v1.0.0
terraform init
terraform plan
terraform apply
```

### Test

```
curl -XGET $(terraform output base_url)/application
```

### Destroy

```
terraform destroy
```
