# Hello World Module
## A Helm Chart for an example Fybrik module

## Introduction

This helm chart defines a common structure to deploy a Kubernetes job for an Fybrik module.

The configuration for the chart is in the values file.

## Prerequisites

- Kubernetes cluster 1.10+
- Helm 3.7+

## Installation

### Modify values in Makefile

In `Makefile`:
- Change `DOCKER_USERNAME`, `DOCKER_PASSWORD`, `DOCKER_HOSTNAME`, `DOCKER_NAMESPACE`, `DOCKER_TAGNAME`, `DOCKER_NAME` to your own preferences.

### Build Docker image for Python application
```bash
make docker-build
```

### Push Docker image to your preferred container registry
```bash
make docker-push
```

### Configure the chart
- When testing the chart, configure settings by editing the `values.yaml` directly.
- Modify repository in `values.yaml` to your preferred Docker image. 
- Modify copy/read action as needed with appropriate values.
- At runtime, the `fybrik-manager` will pass in the copy/read values to the module so you can leave them blank in your final chart. 

### Login to Helm registry
```bash
make helm-login
```

### Lint and install Helm chart
```bash
make helm-verify
```

### Push the Helm chart

```bash
make helm-chart-push
```

## Uninstallation
```bash
make helm-uninstall
```

## Deploy Fybrik module
1. In your module yaml spec (`hello-world-module.yaml`):
    * Change `spec.chart.name` to your preferred chart image.
    * Define `flows` and `capabilities` for your module. 
    * The Fybrik manager checks the `statusIndicators` provided to see if the module is ready. In this example, if the Kubernetes job completes, the status will be `succeeded` and the manager will set the module as ready. 

2. Deploy `FybrikModule` in `fybrik-system` namespace:
```bash
kubectl create -f hello-world-module.yaml -n fybrik-system
```
## Register data asset in Egeria and S3 bucket credentials in Vault (optional)
1. Follow steps 3 and 4 in [this example](https://fybrik.io/dev/samples/notebook/) to register the data asset in the catalog and set the `ASSET_ID` environment variable
2. Follow step 5 in [this example](https://fybrik.io/dev/samples/notebook/) to register HMAC credentials in Vault

## Deploy Fybrik application which triggers module
1. In `fybrikapplication.yaml`:
    * Change `metadata.name` to your application name.
    * Define `appInfo.purpose`, `appInfo.role`, and `spec.data`
    * This ensures that a copy is triggered:
    ```yaml
    copy:
      required:true
    ```
2.  Deploy `FybrikApplication` in `default` namespace:
```bash
cat fybrikapplication.yaml | sed "s/ASSET_ID/$ASSET_ID/g" | kubectl -n default apply -f -
```
3.  Check if `FybrikApplication` successfully deployed:
```bash
kubectl get FybrikApplication -n default
kubectl describe FybrikApplication hello-world-module-test -n default
```

4.  Check if module was triggered in `fybrik-blueprints`:
```bash
kubectl get blueprint -n fybrik-blueprints
kubectl describe blueprint hello-world-module-test-default -n fybrik-blueprints
kubectl get job -n fybrik-blueprints
kubectl get pods -n fybrik-blueprints
```
If you are using the `hello-world-module` image, you should see this in the `kubectl logs` of your completed Pod:
```
$ kubectl logs rel1-hello-world-module-x2tgs

Hello World Module!

Connection name is s3

Connection format is parquet

Vault credential address is http://vault.fybrik-system:8200/

Vault credential role is module

Vault credential secret path is v1/fybrik/dataset-creds/%7B%22asset_id%22:%20%225067b64a-67bc-4067-9117-0aff0a9963ea%22%2C%20%22catalog_id%22:%20%220fd6ff25-7327-4b55-8ff2-56cc1c934824%22%7D

S3 bucket is fybrik-test-bucket

S3 endpoint is s3.eu-gb.cloud-object-storage.appdomain.cloud

COPY SUCCEEDED
```


