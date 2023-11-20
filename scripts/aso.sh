#!/bin/bash

set -euo pipefail

myNamespace="cert-manager"
kubectl get namespace | grep -q "^$myNamespace " || kubectl create namespace $myNamespace
# Removing the following two lines will make the ImagePullBackoff as you get a 403.
#kubectl create namespace 
kubectl label namespace cert-manager cert-manager.io/disable-validation=true

# Apply Cert Manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.12.1/cert-manager.yaml

# Check that every pod in the cert-manager namespace has a STATUS of Running or Completed:
kubectl wait --for=condition=ready pod --all -n cert-manager --timeout=300s

# Add Azure Service Operator
helm repo add aso2 https://raw.githubusercontent.com/Azure/azure-service-operator/main/v2/charts

helm upgrade --install aso2 aso2/azure-service-operator \
    --create-namespace \
    --namespace=azureserviceoperator-system \
    --set azureSubscriptionID=$AZURE_SUBSCRIPTION_ID \
    --set azureTenantID=$AZURE_TENANT_ID \
    --set azureClientID=$AZURE_CLIENT_ID \
    --set azureClientSecret=$AZURE_CLIENT_SECRET \
    --set crdPattern='resources.azure.com/*;apimanagement.azure.com/*'