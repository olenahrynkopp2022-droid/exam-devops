#!/bin/bash

ENV=$1
IMAGE=$2
PORT=$3

echo "ENV=$ENV IMAGE=$IMAGE PORT=$PORT"

# namespace
kubectl create namespace $ENV || true

# 🔍 PRE-CHECK (вимога!)
sed "s|{{NAMESPACE}}|$ENV|g; s|{{IMAGE}}|$IMAGE|g" k8s/deployment.yaml | kubectl apply --dry-run=client -f -
sed "s|{{NAMESPACE}}|$ENV|g; s|{{PORT}}|$PORT|g" k8s/service.yaml | kubectl apply --dry-run=client -f -

if [ $? -ne 0 ]; then
  echo "Pre-check failed ❌"
  exit 1
fi

# 🚀 DEPLOY
sed "s|{{NAMESPACE}}|$ENV|g; s|{{IMAGE}}|$IMAGE|g" k8s/deployment.yaml | kubectl apply -f -
sed "s|{{NAMESPACE}}|$ENV|g; s|{{PORT}}|$PORT|g" k8s/service.yaml | kubectl apply -f -

# 🌐 PORT FORWARD (вимога!)
nohup kubectl port-forward -n $ENV service/app-service $PORT:8000 > pf.log 2>&1 &

echo "Deploy DONE ✅"