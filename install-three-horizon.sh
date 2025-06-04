#!/bin/bash

# Definir namespace
NAMESPACE="three-horizon"

# Verificar se o operador está instalado
echo "Verificando se o operador RHDH está instalado..."
if ! kubectl get pods -n $NAMESPACE -l name=rhdh-operator &>/dev/null; then
  echo "Operador RHDH não encontrado. Verifique se foi instalado corretamente."
  exit 1
fi

# Aplicar o secret do PostgreSQL
echo "Aplicando o segredo do PostgreSQL..."
kubectl apply -f three-horizon-postgres-secret.yaml

# Aplicar o deployment e serviço do PostgreSQL
echo "Configurando o PostgreSQL..."
kubectl apply -f three-horizon-postgres.yaml

# Aguardar o PostgreSQL ficar pronto
echo "Aguardando o PostgreSQL ficar pronto..."
kubectl wait --for=condition=ready pod -l app=three-horizon-postgres -n $NAMESPACE --timeout=300s

# Aplicar o CR Backstage
echo "Aplicando recurso personalizado Backstage..."
kubectl apply -f three-horizon-backstage.yaml

# Aguardar o Backstage ficar pronto
echo "Aguardando o Backstage ficar pronto..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=three-horizon -n $NAMESPACE --timeout=300s

# Aplicar o Ingress
echo "Configurando o Ingress..."
kubectl apply -f three-horizon-ingress.yaml

# Verificar recursos
echo "Verificando recursos criados:"
echo "Pods:"
kubectl get pods -n $NAMESPACE
echo "Serviços:"
kubectl get services -n $NAMESPACE
echo "Ingress:"
kubectl get ingress -n $NAMESPACE
echo "Backstage CR:"
kubectl get backstage -n $NAMESPACE

echo "Instalação completa!"
echo "Acesse o Developer Hub em: http://three-horizon.example.com (ajuste conforme seu domínio)" 