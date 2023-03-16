

### install cert-manger
```shell
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml
```

### Request an EAB key ID and HMAC
```shell
gcloud beta publicca external-account-keys create
```

```shell
Created an external account key
[b64MacKey: ********
keyId: ******]
```

```shell
#preprod
Created an external account key
[b64MacKey: *****
keyId: *****]
```

### store EAB secret in k8s
```shell
kubectl create secret generic eab_secret --from-literal secret=<eab_hmac> -n cert-manager
```

### configure kubernetes service account iam for cert-manager
```
kubectl annotate serviceaccount --namespace=cert-manager cert-manager \
    "iam.gke.io/gcp-service-account=dns01-solver@$PROJECT_ID.iam.gserviceaccount.com"
```