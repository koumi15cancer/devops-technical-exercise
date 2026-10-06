# Task 4 — Terraform

## Deploy dev

```bash
cd terraform
terraform init
terraform apply -var-file=dev.tfvars
```

Verify:

```bash
kubectl get pods -n greeter
curl http://localhost:30080/
curl http://localhost:30080/version
```

Expected: 2 replicas, `Development`, `dev`.

## Deploy prod

```bash
terraform apply -var-file=prod.tfvars
```

Verify:

```bash
kubectl get pods -n greeter
curl http://localhost:30080/
curl http://localhost:30080/version
```

Expected: 3 replicas, `Production`, `prod`.

## Verify Terraform

```bash
terraform plan -var-file=prod.tfvars
terraform state list
```

Expected: no changes and `helm_release.greeter` in state.

The same Terraform configuration is used for both environments , only the
`.tfvars` file changes.

## Cleanup

```bash
terraform destroy -var-file=prod.tfvars
```
