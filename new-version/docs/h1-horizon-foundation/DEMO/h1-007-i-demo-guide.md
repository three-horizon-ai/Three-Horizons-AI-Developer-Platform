# 🎭 H1-007-I: Guia de Demonstração Prática

## 📋 Índice

1. [🎯 Preparação da Demo](#preparacao-demo)
2. [🎬 Roteiro de Demonstração](#roteiro-demonstracao)
3. [💻 Demo 1: Developer Experience](#demo-developer-experience)
4. [🚀 Demo 2: CI/CD e GitOps](#demo-cicd-gitops)
5. [📊 Demo 3: Observabilidade](#demo-observabilidade)
6. [🤖 Demo 4: AI e Automação](#demo-ai-automacao)
7. [🔄 Demo 5: Deployment Progressivo](#demo-deployment-progressivo)
8. [📈 Métricas de Impacto](#metricas-impacto)
9. [🎪 Cenários de Demonstração](#cenarios-demonstracao)
10. [❓ FAQ e Respostas](#faq-respostas)

## 🎯 Preparação da Demo {#preparacao-demo}

### Checklist Pré-Demo

```bash
#!/bin/bash
# scripts/pre-demo-check.sh

echo "🎯 Three Horizons Demo - Pre-flight Check"
echo "========================================"

# Função para verificar status
check_status() {
    local name=$1
    local command=$2
    local expected=$3
    
    echo -n "Checking $name... "
    
    if eval "$command" | grep -q "$expected"; then
        echo "✅ OK"
        return 0
    else
        echo "❌ FAILED"
        return 1
    fi
}

# Verificações
echo ""
echo "🔍 Verificando componentes..."

check_status "Developer Hub" \
    "curl -s https://backstage-rhdh.apps.demo.threehorizons.io/api/health" \
    "ok"

check_status "Portal E-commerce" \
    "curl -s https://portal.demo.threehorizons.io" \
    "<!DOCTYPE html>"

check_status "API Gateway" \
    "curl -s https://api.demo.threehorizons.io/health" \
    "healthy"

check_status "ArgoCD" \
    "argocd app list --grpc-web" \
    "Synced"

check_status "Grafana" \
    "curl -s https://grafana.demo.threehorizons.io/api/health" \
    "ok"

echo ""
echo "📊 Status dos Pods:"
kubectl get pods -n ecommerce-dev --no-headers | awk '{print $1, $3}'

echo ""
echo "🔄 Sync Status:"
argocd app list --output json | jq -r '.[] | "\(.metadata.name): \(.status.sync.status)"'

echo ""
echo "✅ Demo environment is ready!"
```

### Reset para Estado Limpo

```bash
#!/bin/bash
# scripts/reset-demo-env.sh

echo "🔄 Resetando ambiente para demo..."

# Limpar dados de teste
kubectl delete jobs --all -n ecommerce-dev
kubectl exec -n ecommerce-dev deployment/catalog-service -- npm run seed:demo

# Reset métricas
curl -X POST https://prometheus.demo.threehorizons.io/api/v1/admin/tsdb/clean_tombstones

# Limpar logs antigos
kubectl delete pods -n monitoring -l app=loki --force --grace-period=0

# Reset ArgoCD sync
argocd app sync ecommerce-platform --force

echo "✅ Ambiente resetado!"
```

## 🎬 Roteiro de Demonstração {#roteiro-demonstracao}

### Estrutura da Apresentação (30 minutos)

```markdown
# 🎯 Three Horizons AI Platform Demo

## ⏱️ Agenda (30 min)

### 1. Introdução (3 min)
- Visão da plataforma
- Objetivos e benefícios
- Arquitetura alto nível

### 2. Developer Experience (8 min)
- Developer Hub walkthrough
- Criação de novo projeto
- Ambiente de desenvolvimento (DevBox)
- Templates e Golden Paths

### 3. CI/CD e GitOps (7 min)
- Pipeline automatizado
- GitOps com ArgoCD
- Deployment progressivo
- Rollback automático

### 4. Observabilidade (5 min)
- Dashboards em tempo real
- Alertas e incidentes
- Distributed tracing
- SLO/SLI tracking

### 5. AI e Automação (5 min)
- GitHub Copilot integração
- Auto-scaling inteligente
- Recomendações AI
- Análise preditiva

### 6. Q&A (2 min)
```

### Script de Apresentação

```typescript
// demo/presentation-script.ts
export const demoScript = {
  introduction: {
    duration: "3 minutes",
    talking_points: [
      "Bem-vindos à demonstração do Three Horizons AI Platform",
      "Uma plataforma unificada que combina Azure, GitHub e Red Hat",
      "Foco em developer experience e automação inteligente",
      "Redução de 70% no tempo de onboarding de novos projetos"
    ],
    actions: [
      "Mostrar slide de arquitetura",
      "Abrir Developer Hub em nova aba",
      "Ter terminal pronto com comandos"
    ]
  },
  
  developer_experience: {
    duration: "8 minutes",
    demo_flow: [
      {
        step: "Login no Developer Hub",
        url: "https://backstage-rhdh.apps.demo.threehorizons.io",
        script: "Fazer login com GitHub OAuth"
      },
      {
        step: "Explorar catálogo",
        actions: [
          "Mostrar componentes existentes",
          "Filtrar por team e tipo",
          "Abrir detalhes de um serviço"
        ]
      },
      {
        step: "Criar novo projeto",
        actions: [
          "Clicar em 'Create Component'",
          "Selecionar template 'E-commerce Portal'",
          "Preencher formulário",
          "Mostrar opções de features"
        ]
      },
      {
        step: "Acompanhar criação",
        script: "Mostrar logs em tempo real e explicar automações"
      }
    ]
  }
}
```

## 💻 Demo 1: Developer Experience {#demo-developer-experience}

### Passo a Passo Detalhado

```bash
# 1. Acessar Developer Hub
open https://backstage-rhdh.apps.demo.threehorizons.io

# 2. Login com GitHub
# Clicar em "Sign in with GitHub"
# Autorizar aplicação

# 3. Explorar Catálogo
# - Navegar por Systems > E-commerce Platform
# - Mostrar dependencies graph
# - Abrir documentação inline

# 4. Criar Novo Componente
# - Clicar em "Create Component"
# - Selecionar "E-commerce Portal"
# - Preencher:
#   Nome: demo-store
#   Descrição: Demo store for Three Horizons
#   Owner: platform-team
#   Features: Ativar todas

# 5. Mostrar automações em execução
```

### Comandos para Demonstrar

```bash
# Verificar criação do repositório
gh repo view three-horizon-ai/demo-store

# Verificar pipeline iniciado
gh run list --repo three-horizon-ai/demo-store

# Verificar recursos Azure criados
az resource list --resource-group rg-demo-store-dev --output table

# Acessar DevBox criado
open https://devbox-demo-store.dev.azure.com
```

### Pontos-Chave a Destacar

1. **Zero configuração manual** - Tudo automatizado
2. **Segurança by default** - RBAC, secrets management
3. **Best practices incorporadas** - Linting, testing, security scanning
4. **Documentação automática** - TechDocs gerado do código

## 🚀 Demo 2: CI/CD e GitOps {#demo-cicd-gitops}

### Demonstração de Pipeline

```bash
# 1. Fazer uma mudança no código
cd demo-store
echo "<!-- Demo change -->" >> frontend/portal/pages/index.tsx
git add .
git commit -m "feat: Demo change for Three Horizons"
git push

# 2. Mostrar pipeline em execução
open https://github.com/three-horizon-ai/demo-store/actions

# 3. Acompanhar no ArgoCD
open https://argocd.demo.threehorizons.io
```

### Deployment Progressivo

```yaml
# Demonstrar canary deployment
# 1. Mostrar configuração Flagger
kubectl get canaries -n ecommerce-dev

# 2. Trigger deployment
kubectl set image deployment/frontend-portal \
  frontend-portal=acrthreehorizonsdemo.azurecr.io/frontend-portal:v2.0.0 \
  -n ecommerce-dev

# 3. Acompanhar métricas
watch kubectl get canary frontend-portal -n ecommerce-dev

# 4. Mostrar tráfego sendo dividido
while true; do
  curl -s https://portal-dev.demo.threehorizons.io/api/version
  sleep 1
done
```

### Rollback Automático

```bash
# Simular falha
kubectl patch canary frontend-portal -n ecommerce-dev \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/analysis/metrics/0/thresholdRange/min", "value": 99.99}]'

# Observar rollback automático
kubectl describe canary frontend-portal -n ecommerce-dev
```

## 📊 Demo 3: Observabilidade {#demo-observabilidade}

### Dashboard Tour

```javascript
// Scripts para gerar carga
const generateLoad = async () => {
  const endpoints = [
    'https://api.demo.threehorizons.io/products',
    'https://api.demo.threehorizons.io/cart',
    'https://api.demo.threehorizons.io/users/profile'
  ];
  
  // Gerar requisições normais
  for (let i = 0; i < 100; i++) {
    const endpoint = endpoints[Math.floor(Math.random() * endpoints.length)];
    fetch(endpoint).catch(() => {});
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  
  // Gerar alguns erros
  for (let i = 0; i < 10; i++) {
    fetch('https://api.demo.threehorizons.io/error').catch(() => {});
  }
};

// Executar
generateLoad();
```

### Demonstrar Funcionalidades

1. **Grafana Dashboards**
   ```
   - Abrir https://grafana.demo.threehorizons.io
   - Mostrar dashboard "Platform Overview"
   - Drill down em serviço específico
   - Mostrar correlação entre métricas
   ```

2. **Distributed Tracing**
   ```
   - Abrir Grafana > Explore > Tempo
   - Buscar trace de requisição lenta
   - Mostrar timeline e spans
   - Identificar bottleneck
   ```

3. **Alertas em Ação**
   ```bash
   # Simular alta latência
   kubectl exec -n ecommerce-dev deployment/catalog-service -- \
     curl -X POST http://localhost:8080/debug/latency?ms=5000
   
   # Verificar alerta disparado
   open https://grafana.demo.threehorizons.io/alerting/list
   ```

## 🤖 Demo 4: AI e Automação {#demo-ai-automacao}

### GitHub Copilot em Ação

```typescript
// Abrir VS Code no DevBox
// Demonstrar Copilot sugerindo código

// Exemplo 1: Criar nova função
// Digite: "// Function to calculate discount based on user history"
// Mostrar sugestão do Copilot

// Exemplo 2: Testes automatizados
// Digite: "describe('CartService"
// Mostrar geração de testes

// Exemplo 3: Documentação
// Digite: "/**"
// Mostrar geração de JSDoc
```

### AI-Powered Insights

```bash
# Mostrar recomendações de otimização
curl https://api.demo.threehorizons.io/ai/recommendations | jq

# Exemplo de resposta:
{
  "recommendations": [
    {
      "type": "scaling",
      "service": "catalog-service",
      "action": "increase_replicas",
      "reason": "Predicted traffic spike in 2 hours",
      "confidence": 0.92
    },
    {
      "type": "cost_optimization",
      "service": "user-service",
      "action": "reduce_memory",
      "reason": "Consistently using only 40% of allocated memory",
      "potential_savings": "$120/month"
    }
  ]
}
```

### Auto-remediation Demo

```yaml
# Mostrar configuração de auto-healing
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: auto-remediation
spec:
  groups:
  - name: auto-heal
    rules:
    - alert: PodCrashLooping
      expr: rate(kube_pod_container_status_restarts_total[1h]) > 5
      for: 5m
      annotations:
        action: "restart_deployment"
        runbook_url: "automated"
```

## 🔄 Demo 5: Deployment Progressivo {#demo-deployment-progressivo}

### Blue-Green Deployment

```bash
# 1. Estado atual (Blue)
kubectl get svc frontend-portal-active -n ecommerce-prod -o yaml | grep -A 2 selector

# 2. Deploy nova versão (Green)
./scripts/blue-green-deploy.sh frontend-portal v2.0.0 prod

# 3. Mostrar ambos ambientes rodando
kubectl get pods -n ecommerce-prod -l app=frontend-portal

# 4. Switch traffic
kubectl patch svc frontend-portal-active -n ecommerce-prod \
  -p '{"spec":{"selector":{"color":"green"}}}'

# 5. Verificar nova versão
curl https://portal.demo.threehorizons.io/api/version
```

### Feature Flags Demo

```typescript
// Mostrar integração com LaunchDarkly
const features = {
  aiRecommendations: await ldClient.variation('ai-recommendations', user, false),
  advancedSearch: await ldClient.variation('advanced-search', user, false),
  socialLogin: await ldClient.variation('social-login', user, false)
};

// Toggle feature em tempo real
// Abrir LaunchDarkly dashboard
// Ativar 'ai-recommendations'
// Mostrar mudança instantânea no app
```

## 📈 Métricas de Impacto {#metricas-impacto}

### Dashboard de Métricas DORA

```sql
-- Queries para demonstrar melhorias

-- Lead Time for Changes
SELECT 
  DATE_TRUNC('week', created_at) as week,
  AVG(EXTRACT(EPOCH FROM (deployed_at - committed_at))/3600) as lead_time_hours
FROM deployments
WHERE created_at > NOW() - INTERVAL '3 months'
GROUP BY week
ORDER BY week;
-- Resultado: Redução de 72h para 2h

-- Deployment Frequency
SELECT 
  DATE_TRUNC('day', deployed_at) as day,
  COUNT(*) as deployments
FROM deployments
WHERE deployed_at > NOW() - INTERVAL '1 month'
  AND environment = 'production'
GROUP BY day;
-- Resultado: De 1/semana para 15/dia

-- Mean Time to Recovery
SELECT 
  AVG(EXTRACT(EPOCH FROM (resolved_at - created_at))/60) as mttr_minutes
FROM incidents
WHERE created_at > NOW() - INTERVAL '3 months'
  AND severity = 'critical';
-- Resultado: De 4h para 15min

-- Change Failure Rate
SELECT 
  COUNT(CASE WHEN rollback = true THEN 1 END)::float / COUNT(*) * 100 as failure_rate
FROM deployments
WHERE deployed_at > NOW() - INTERVAL '1 month';
-- Resultado: De 15% para 1.2%
```

### ROI Calculator

```typescript
// components/roi-calculator.tsx
export function ROICalculator() {
  const metrics = {
    developerHours: {
      before: 40, // hours per feature
      after: 12,  // hours per feature
      hourlyRate: 150
    },
    deploymentTime: {
      before: 4, // hours
      after: 0.25, // 15 minutes
      deploymentsPerMonth: 50
    },
    incidentCost: {
      before: 25000, // per incident
      after: 5000,
      incidentsPerMonth: 2
    }
  };
  
  const monthlySavings = 
    (metrics.developerHours.before - metrics.developerHours.after) * 
    metrics.developerHours.hourlyRate * 20 + // 20 features/month
    (metrics.deploymentTime.before - metrics.deploymentTime.after) * 
    metrics.deploymentTime.deploymentsPerMonth * 100 + // deployment cost
    (metrics.incidentCost.before - metrics.incidentCost.after) * 
    metrics.incidentCost.incidentsPerMonth;
  
  return (
    <div className="roi-dashboard">
      <h2>Monthly Savings: ${monthlySavings.toLocaleString()}</h2>
      <h3>Annual ROI: ${(monthlySavings * 12).toLocaleString()}</h3>
    </div>
  );
}
```

## 🎪 Cenários de Demonstração {#cenarios-demonstracao}

### Cenário 1: Novo Desenvolvedor

```bash
# Timeline: Onboarding em 30 minutos

# 00:00 - Recebe convite por email
# 00:05 - Acessa Developer Hub e faz login
# 00:10 - Explora documentação e catálogo
# 00:15 - Cria primeiro projeto usando template
# 00:20 - Acessa DevBox configurado
# 00:25 - Faz primeiro commit
# 00:30 - Vê aplicação rodando em dev

# Comando para simular
./demo/scenarios/new-developer-onboarding.sh "john@example.com"
```

### Cenário 2: Incidente em Produção

```bash
# Timeline: Resolução em 15 minutos

# 00:00 - Alerta disparado (Error rate > 5%)
# 00:01 - PagerDuty notifica on-call
# 00:03 - Developer acessa Grafana
# 00:05 - Identifica problema via traces
# 00:08 - Cria hotfix
# 00:10 - Deploy via GitOps
# 00:12 - Canary deployment inicia
# 00:15 - Problema resolvido, métricas normais

# Comando para simular
./demo/scenarios/production-incident.sh
```

### Cenário 3: Feature Launch

```bash
# Timeline: Feature completa em 2 dias

# Dia 1 - Manhã: Requisitos definidos
# Dia 1 - Tarde: Desenvolvimento com Copilot
# Dia 2 - Manhã: Testes e code review
# Dia 2 - Tarde: Deploy progressivo
# Dia 2 - Final: Feature em produção

# Mostrar:
# - Velocity aumentada com AI
# - Qualidade mantida (coverage > 80%)
# - Zero downtime deployment
# - Feature flags para rollout controlado
```

## ❓ FAQ e Respostas {#faq-respostas}

### Perguntas Técnicas Comuns

```markdown
**Q: Como é feita a integração com sistemas legados?**
A: Oferecemos adapters e APIs Gateway que permitem integração gradual. 
   Exemplo: Legacy SOAP -> API Gateway -> REST/GraphQL

**Q: Qual o overhead de performance da plataforma?**
A: < 1% de latência adicional devido ao service mesh otimizado.
   Métricas: P99 latency < 10ms para service-to-service

**Q: Como funciona o disaster recovery?**
A: Multi-region setup com RTO < 1h e RPO < 5min.
   Backups automáticos a cada 4h, replicação cross-region.

**Q: Posso usar minha própria cloud?**
A: Sim, suportamos Azure, AWS, GCP e on-premises via Azure Arc.

**Q: Como é o modelo de custos?**
A: Baseado em consumo + licenças Red Hat. 
   Estimativa: $50-100 per developer/month incluindo infra.
```

### Objeções Comuns

```typescript
const objectionHandlers = {
  "muito_complexo": {
    response: "Abstraímos a complexidade com templates e automação",
    demo: "Mostrar criação de app em 5 minutos"
  },
  
  "vendor_lock_in": {
    response: "Baseado em padrões abertos (K8s, OCI, GitOps)",
    demo: "Mostrar portabilidade entre clouds"
  },
  
  "seguranca": {
    response: "Security by default, shift-left, zero-trust",
    demo: "Mostrar security scanning e compliance dashboard"
  },
  
  "roi_incerto": {
    response: "ROI médio de 6 meses baseado em clientes atuais",
    demo: "Abrir calculadora de ROI com números reais"
  }
};
```

### Scripts de Resposta

```javascript
// Respostas preparadas para situações comuns

const demoResponses = {
  erro_durante_demo: {
    action: "Isso ilustra perfeitamente nosso auto-healing!",
    followup: "Veja como o sistema já está se recuperando automaticamente"
  },
  
  pergunta_nao_preparada: {
    action: "Excelente pergunta! Vou anotar para dar uma resposta completa",
    followup: "Mas posso mostrar algo relacionado..."
  },
  
  ceticismo_sobre_ai: {
    action: "Entendo a preocupação. O AI é assistivo, não substitutivo",
    demo: "Mostrar como Copilot sugere mas developer decide"
  }
};
```

---

## 🎯 Checklist Final da Demo

```bash
#!/bin/bash
# Pre-demo checklist

echo "[ ] Ambiente resetado e funcional"
echo "[ ] Credenciais de acesso testadas"
echo "[ ] Scripts de demo preparados"
echo "[ ] Backup em caso de falha"
echo "[ ] Slides atualizados"
echo "[ ] Conexão internet estável"
echo "[ ] Gravação de tela pronta"
echo "[ ] Água e notas à mão"
echo ""
echo "🎭 Break a leg!"
```

---

**📝 Dicas para Apresentador**

1. **Mantenha o ritmo** - 1 minuto por slide/demo
2. **Foque nos benefícios** - Não apenas features
3. **Use casos reais** - Não demos artificiais
4. **Antecipe perguntas** - Tenha dados prontos
5. **Demonstre confiança** - A plataforma funciona!