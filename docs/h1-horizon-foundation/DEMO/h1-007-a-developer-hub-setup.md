# 🏠 H1-007-A: Guia Completo de Configuração do Developer Hub

## 📋 Índice

1. [🎯 Visão Geral](#visao-geral)
2. [✅ Pré-requisitos](#pre-requisitos)
3. [🔐 Configuração de Acesso](#configuracao-acesso)
4. [🐙 Integração GitHub](#integracao-github)
5. [📚 Configuração do Catálogo](#configuracao-catalogo)
6. [🎨 Criação de Templates](#criacao-templates)
7. [🔧 Configuração de Plugins](#configuracao-plugins)
8. [👥 Gestão de Usuários](#gestao-usuarios)
9. [🧪 Validação e Testes](#validacao-testes)
10. [🔍 Troubleshooting](#troubleshooting)

## 🎯 Visão Geral {#visao-geral}

Este guia fornece instruções detalhadas para configurar completamente o Red Hat Developer Hub (Backstage) para a demonstração do Three Horizons AI Platform.

### 📊 Informações do Ambiente

- **URL do Developer Hub**: `https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io/`
- **Versão**: Red Hat Developer Hub 1.6
- **Autenticação**: GitHub OAuth
- **Namespace Kubernetes**: `rhdh-operator`

## ✅ Pré-requisitos {#pre-requisitos}

### 🛠️ Ferramentas Necessárias

```bash
# Verificar instalação das ferramentas
az --version          # Azure CLI >= 2.50.0
gh --version          # GitHub CLI >= 2.35.0
kubectl version       # Kubernetes CLI >= 1.28.0
oc version           # OpenShift CLI >= 4.12
git --version        # Git >= 2.30.0
jq --version         # JSON processor >= 1.6
```

### 🔑 Acessos Necessários

1. **GitHub**
   - Conta com acesso à organização `three-horizon-ai`
   - Permissões para criar GitHub Apps
   - Token pessoal com escopo `repo, workflow, admin:org`

2. **Azure**
   - Subscription: `ME-MngEnvMCAP178642-paulasilva-1`
   - Role: Contributor ou Owner
   - Acesso ao AKS cluster

3. **OpenShift/Kubernetes**
   - Acesso ao cluster ARO
   - Permissões no namespace `rhdh-operator`

## 🔐 Configuração de Acesso {#configuracao-acesso}

### Passo 1: Login no Azure e Kubernetes

```bash
# Login no Azure
az login
az account set --subscription "aca2dc4a-9d62-4b64-82d4-11e152d98f02"

# Obter credenciais do AKS
az aks get-credentials \
  --resource-group rhdh-operator \
  --name threehorizons-aks \
  --overwrite-existing

# Verificar acesso
kubectl get pods -n rhdh-operator
```

### Passo 2: Acessar o Developer Hub

1. Abra o navegador e acesse: https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io/
2. Clique em **"Sign In"**
3. Selecione **"Sign in with GitHub"**
4. Autorize o aplicativo quando solicitado
5. Você será redirecionado de volta ao Developer Hub

## 🐙 Integração GitHub {#integracao-github}

### Passo 1: Criar GitHub App

1. Acesse: https://github.com/organizations/three-horizon-ai/settings/apps
2. Clique em **"New GitHub App"**
3. Preencha os campos:

```yaml
GitHub App name: Three Horizons Developer Hub
Homepage URL: https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io

Authorization callback URL:
https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io/api/auth/github/handler/frame

Webhook URL:
https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io/api/github/webhook

Webhook secret: [Gerar um secret seguro]
```

### Passo 2: Configurar Permissões

Marque as seguintes permissões:

**Repository permissions:**
- Actions: Read
- Administration: Read & Write
- Contents: Read & Write
- Issues: Read & Write
- Metadata: Read
- Pull requests: Read & Write
- Webhooks: Read & Write

**Organization permissions:**
- Members: Read
- Plan: Read

**Account permissions:**
- Email addresses: Read

### Passo 3: Eventos do Webhook

Selecione os seguintes eventos:
- Push
- Pull request
- Repository
- Release
- Workflow run

### Passo 4: Gerar Private Key

1. Após criar o app, role até **"Private keys"**
2. Clique em **"Generate a private key"**
3. Salve o arquivo `.pem` baixado

### Passo 5: Instalar o GitHub App

1. Na página do app, clique em **"Install"**
2. Selecione a organização **"three-horizon-ai"**
3. Escolha **"All repositories"**
4. Clique em **"Install"**

### Passo 6: Configurar Secrets no Kubernetes

```bash
# Salvar as credenciais do GitHub App
GITHUB_APP_ID="123456"  # Substituir pelo App ID real
GITHUB_CLIENT_ID="Iv1.abc123def456"  # Substituir pelo Client ID real
GITHUB_CLIENT_SECRET="your-client-secret"  # Substituir pelo Client Secret real
GITHUB_WEBHOOK_SECRET="your-webhook-secret"  # Substituir pelo Webhook Secret real

# Criar secret no Kubernetes
kubectl create secret generic github-app-credentials \
  --from-literal=GITHUB_APP_ID="$GITHUB_APP_ID" \
  --from-literal=GITHUB_CLIENT_ID="$GITHUB_CLIENT_ID" \
  --from-literal=GITHUB_CLIENT_SECRET="$GITHUB_CLIENT_SECRET" \
  --from-literal=GITHUB_WEBHOOK_SECRET="$GITHUB_WEBHOOK_SECRET" \
  --from-file=GITHUB_APP_PRIVATE_KEY=path/to/private-key.pem \
  -n rhdh-operator \
  --dry-run=client -o yaml | kubectl apply -f -
```

### Passo 7: Atualizar ConfigMap do Developer Hub

```bash
# Editar a configuração do Developer Hub
kubectl edit configmap backstage-config -n rhdh-operator
```

Adicione/atualize a seção de integração:

```yaml
data:
  app-config.yaml: |
    app:
      title: Three Horizons AI Platform
      baseUrl: https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io
    
    backend:
      baseUrl: https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io
      cors:
        origin: https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io
    
    integrations:
      github:
        - host: github.com
          apps:
            - appId: ${GITHUB_APP_ID}
              clientId: ${GITHUB_CLIENT_ID}
              clientSecret: ${GITHUB_CLIENT_SECRET}
              privateKey: |
                ${GITHUB_APP_PRIVATE_KEY}
              webhookSecret: ${GITHUB_WEBHOOK_SECRET}
    
    auth:
      environment: production
      providers:
        github:
          production:
            clientId: ${GITHUB_CLIENT_ID}
            clientSecret: ${GITHUB_CLIENT_SECRET}
```

### Passo 8: Reiniciar o Developer Hub

```bash
# Forçar reinicialização
kubectl rollout restart deployment/backstage -n rhdh-operator

# Aguardar pods ficarem prontos
kubectl wait --for=condition=ready pod -l app=backstage -n rhdh-operator --timeout=300s

# Verificar logs
kubectl logs -f deployment/backstage -n rhdh-operator
```

## 📚 Configuração do Catálogo {#configuracao-catalogo}

### Passo 1: Criar Estrutura Base do Catálogo

Crie o arquivo `catalog-locations.yaml`:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: three-horizons-root
  description: Three Horizons AI Platform Root Catalog
spec:
  type: url
  targets:
    - https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform/blob/main/catalog-info.yaml
    - https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform/blob/demo/ecommerce-showcase/demos/ecommerce-showcase/catalog-info.yaml
```

### Passo 2: Registrar Localizações no Developer Hub

1. No Developer Hub, navegue para **Catalog → Register Existing Component**
2. Selecione **"URL"**
3. Cole a URL: `https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform/blob/main/catalog-locations.yaml`
4. Clique em **"Analyze"**
5. Revise as entidades descobertas
6. Clique em **"Import"**

### Passo 3: Criar Domínios e Sistemas

Crie o arquivo `domains.yaml` no repositório:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: three-horizons
  description: Three Horizons AI Platform
  links:
    - url: https://threehorizons.ai
      title: Website
spec:
  owner: platform-team
---
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: developer-experience
  description: Developer Experience Platform
spec:
  owner: platform-team
  domain: three-horizons
---
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: ecommerce-platform
  description: E-commerce Demo Platform
spec:
  owner: platform-team
  domain: three-horizons
```

### Passo 4: Criar Grupos e Usuários

Crie o arquivo `org.yaml`:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: platform-team
  description: Platform Engineering Team
spec:
  type: team
  profile:
    displayName: Platform Team
    email: platform@threehorizons.ai
  children: []
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: developers
  description: Development Teams
spec:
  type: team
  profile:
    displayName: Developers
    email: dev@threehorizons.ai
  children: []
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: paula.silva
spec:
  profile:
    displayName: Paula Silva
    email: paula.silva@threehorizons.ai
  memberOf: [platform-team, developers]
```

## 🎨 Criação de Templates {#criacao-templates}

### Passo 1: Estrutura de Templates

Crie a seguinte estrutura no repositório:

```
demos/ecommerce-showcase/templates/
├── catalog-info.yaml
└── ecommerce-fullstack/
    ├── template.yaml
    └── skeleton/
        ├── .github/
        ├── frontend/
        ├── backend/
        ├── infrastructure/
        └── docs/
```

### Passo 2: Registrar Templates

1. No Developer Hub, vá para **Catalog → Register Existing Component**
2. Use a URL: `https://github.com/three-horizon-ai/Three-Horizons-AI-Developer-Platform/blob/demo/ecommerce-showcase/demos/ecommerce-showcase/templates/catalog-info.yaml`
3. Analise e importe

### Passo 3: Verificar Templates

1. Navegue para a página **Create**
2. Os templates devem aparecer listados
3. Teste criando um projeto de exemplo

## 🔧 Configuração de Plugins {#configuracao-plugins}

### Plugins Essenciais Instalados

- **Catalog**: Gerenciamento de componentes
- **Scaffolder**: Criação de projetos
- **TechDocs**: Documentação
- **GitHub Actions**: CI/CD
- **Kubernetes**: Visualização de recursos

### Configurar Plugin Kubernetes

```yaml
kubernetes:
  serviceLocatorMethod:
    type: 'multiTenant'
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - name: threehorizons-aks
          url: https://threehorizons-aks-dns-xxxxxxxx.hcp.centralus.azmk8s.io
          authProvider: 'azure'
          serviceAccountToken: ${K8S_TOKEN}
```

## 👥 Gestão de Usuários {#gestao-usuarios}

### Configurar Sincronização com GitHub

```yaml
catalog:
  providers:
    github:
      - organization: 'three-horizon-ai'
        catalogPath: '/catalog-info.yaml'
        filters:
          branch: 'main'
          repository: '.*'
        schedule:
          frequency: { minutes: 30 }
          timeout: { minutes: 3 }
```

## 🧪 Validação e Testes {#validacao-testes}

### Script de Validação

```bash
#!/bin/bash
# validate-setup.sh

echo "🔍 Validando configuração do Developer Hub..."

# 1. Testar conectividade
echo "✓ Testando conectividade..."
curl -s -o /dev/null -w "%{http_code}" https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io/api/health

# 2. Verificar autenticação GitHub
echo "✓ Verificando GitHub..."
gh api /orgs/three-horizon-ai

# 3. Verificar catálogo
echo "✓ Verificando catálogo..."
curl -H "Authorization: Bearer $TOKEN" \
  https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io/api/catalog/entities

# 4. Testar criação de template
echo "✓ Testando templates..."
# Navegue manualmente e teste

echo "✅ Validação concluída!"
```

## 🔍 Troubleshooting {#troubleshooting}

### Problemas Comuns

| Problema | Solução |
|----------|---------|
| Login falha | Verificar GitHub App credentials |
| Templates não aparecem | Verificar catalog location URLs |
| Kubernetes não conecta | Verificar service account token |
| Webhooks falham | Verificar webhook secret e URL |

### Comandos Úteis

```bash
# Ver logs do Developer Hub
kubectl logs -f deployment/backstage -n rhdh-operator

# Verificar configuração
kubectl get configmap backstage-config -n rhdh-operator -o yaml

# Testar GitHub webhook
curl -X POST https://backstage-rhdh-rhdh-operator.apps.txl952sg.centralus.aroapp.io/api/github/webhook \
  -H "X-GitHub-Event: ping" \
  -H "X-Hub-Signature: sha1=YOUR_SIGNATURE"

# Limpar cache do catálogo
kubectl exec -it deployment/backstage -n rhdh-operator -- \
  curl -X POST http://localhost:7007/api/catalog/refresh
```

---

## 🎯 Próximos Passos

Com o Developer Hub configurado, siga para:

1. **[H1-007-B: Criação de Templates](./H1-007-B-template-creation.md)** - Criar templates completos
2. **[H1-007-C: Configuração Azure](./H1-007-C-azure-configuration.md)** - Configurar infraestrutura
3. **[H1-007-D: Desenvolvimento da Aplicação](./H1-007-D-application-development.md)** - Criar aplicação demo

---

**📝 Checklist Final**

- [ ] GitHub App criado e instalado
- [ ] Secrets configurados no Kubernetes
- [ ] ConfigMap atualizado com integrações
- [ ] Catálogo registrado e sincronizando
- [ ] Templates visíveis na página Create
- [ ] Autenticação funcionando corretamente