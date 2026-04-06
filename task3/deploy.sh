#!/bin/bash

# Отримуємо аргументи
ENV=$1
IMAGE=$2
PORT=$3

# Перевірка наявності аргументів
if [[ -z "$ENV" || -z "$IMAGE" || -z "$PORT" ]]; then
    echo "Usage: ./deploy.sh <env> <image> <port>"
    exit 1
fi

echo "--- Starting Deployment ---"
echo "Environment: $ENV"
echo "Image:       $IMAGE"
echo "Port:        $PORT"

# 1. Створення Namespace (якщо не існує)
kubectl create namespace $ENV --dry-run=client -o yaml | kubectl apply -f -

# 2. 🔍 PRE-CHECK (Dry-run на стороні сервера для повної впевненості)
echo "Running Pre-check (Dry-run)..."

# Замінюємо змінні та перевіряємо валідність YAML
sed "s/{{NAMESPACE}}/$ENV/g; s|{{IMAGE}}|$IMAGE|g" k8s/deployment.yaml | kubectl apply --dry-run=server -f -
DEP_STATUS=$?

sed "s/{{NAMESPACE}}/$ENV/g; s/{{PORT}}/$PORT/g" k8s/service.yaml | kubectl apply --dry-run=server -f -
SVC_STATUS=$?

if [ $DEP_STATUS -ne 0 ] || [ $SVC_STATUS -ne 0 ]; then
  echo "Pre-check failed ❌ (Check your YAML syntax or variable placeholders)"
  exit 1
fi

echo "Pre-check passed ✅"

# 3. 🚀 REAL DEPLOY
echo "Deploying to Kubernetes..."
sed "s/{{NAMESPACE}}/$ENV/g; s|{{IMAGE}}|$IMAGE|g" k8s/deployment.yaml | kubectl apply -f -
sed "s/{{NAMESPACE}}/$ENV/g; s/{{PORT}}/$PORT/g" k8s/service.yaml | kubectl apply -f -

# 4. 🌐 PORT FORWARD (вимога завдання)
echo "Setting up Port-forwarding on port $PORT..."

# Вбиваємо старий процес port-forward на цьому порті, якщо він є
old_pf_pid=$(pgrep -f "port-forward.*$PORT:8000")
if [ -not -z "$old_pf_pid" ]; then
    kill -9 $old_pf_pid
fi

# Запускаємо новий port-forward у фоні
# --address 0.0.0.0 дозволяє підключатися зовні до IP сервера
nohup kubectl port-forward --address 0.0.0.0 -n $ENV service/app-service $PORT:8000 > pf_$ENV.log 2>&1 &

echo "Deploy DONE ✅"
echo "App should be available at http://<VM_IP>:$PORT"
