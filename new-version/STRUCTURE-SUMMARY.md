# 📁 Estrutura Final Organizada - Three Horizons AI Platform

## 🎯 Organização Simplificada e Centralizada

### ✅ **RESPOSTA**: Scripts e templates ficam organizados em `assets/`

A estrutura foi simplificada para centralizar todos os recursos em um único diretório `assets`, evitando duplicação e facilitando a navegação:

```
new-version/
├── 📚 docs/                          # Documentação organizada por horizonte
│   ├── README.md                     # Índice principal de navegação
│   ├── h1-horizon-foundation/        # Horizon 1: Foundation
│   ├── h2-horizon-optimization/      # Horizon 2: Optimization  
│   ├── h3-horizon-innovation/        # Horizon 3: Innovation
│   ├── guides/                       # Guias para desenvolvedores
│   └── reference/                    # Documentação de referência
│
└── 🛠️ assets/                        # TODOS os recursos centralizados
    ├── 📊 diagrams/                  # Diagramas SVG e Mermaid
    ├── 🖼️ images/                    # Logos e imagens do platform
    ├── 🔧 scripts/                   # Scripts organizados por horizon
    │   ├── h1-foundation/            # Scripts do Horizon 1
    │   ├── h2-optimization/          # Scripts do Horizon 2
    │   ├── h3-innovation/            # Scripts do Horizon 3
    │   └── shared/                   # Scripts de automação geral
    └── 📄 templates/                 # Templates reutilizáveis
        ├── bicep/                    # Templates de infraestrutura
        ├── github-actions/           # Templates de CI/CD
        ├── helm-charts/              # Templates Kubernetes
        └── documentation/            # Templates de documentação
```

## 🔧 Scripts por Horizon

### **Horizon 1 (Foundation)** - `assets/scripts/h1-foundation/`
- ✅ **Finalidade**: Setup básico da plataforma
- 📂 **Conteúdo**: Scripts de deploy de infraestrutura, configuração de segurança básica, integração GitHub, deploy do Developer Hub, CI/CD básico

### **Horizon 2 (Optimization)** - `assets/scripts/h2-optimization/`
- ✅ **Finalidade**: Otimização e funcionalidades avançadas
- 📂 **Conteúdo**: GitOps, monitoramento avançado, segurança aprimorada, otimização de performance, golden paths

### **Horizon 3 (Innovation)** - `assets/scripts/h3-innovation/`
- ✅ **Finalidade**: Recursos de AI e automação
- 📂 **Conteúdo**: Integração AI, Azure AI Foundry, operações autônomas, MCP, analytics avançados

### **Scripts Compartilhados** - `assets/scripts/shared/`
- ✅ **Finalidade**: Automação e utilitários gerais
- 📂 **Conteúdo**: Navegação de docs, validação de links, reorganização, funções comuns

## 📄 Templates por Categoria

### **Infrastructure (Bicep)** - `assets/templates/bicep/`
- Foundation templates para recursos básicos
- Optimization templates para configurações avançadas  
- Innovation templates para recursos AI

### **CI/CD (GitHub Actions)** - `assets/templates/github-actions/`
- Build workflows para diferentes tipos de aplicação
- Deployment pipelines para cada horizon
- Security scanning e compliance checks

### **Kubernetes (Helm)** - `assets/templates/helm-charts/`
- Application charts para deployments padrão
- Platform charts para componentes do Developer Hub
- AI workload charts para aplicações ML/AI

### **Documentation** - `assets/templates/documentation/`
- Document templates com navegação
- API documentation templates
- Troubleshooting guides templates

## 🔗 Convenções de Referência

### **Em Documentos (.md)**
```markdown
# Diagramas e imagens
![Architecture](../assets/diagrams/architecture-diagram.svg)
![Logo](../assets/images/Three-Horizon.svg)

# Links para scripts
[Deploy Script](../assets/scripts/h1-foundation/deploy-infrastructure.sh)

# Links para templates  
[Bicep Template](../assets/templates/bicep/foundation-template.bicep)
```

### **Em Scripts (.sh)**
```bash
# Referência a utilitários compartilhados
source "../shared/common-functions.sh"

# Uso de templates
cp "../../templates/bicep/foundation-template.bicep" ./main.bicep
```

## 🎯 Benefícios da Organização

### ✅ **Centralização**
- Todos os recursos em `assets/`
- Evita duplicação de diagramas e scripts
- Facilita manutenção e localização

### ✅ **Hierarquia Clara**
- Scripts organizados por horizon de implementação
- Templates categorizados por tecnologia
- Documentação estruturada progressivamente

### ✅ **Navegação Simplificada**
- Links padronizados `../assets/[categoria]/[arquivo]`
- Breadcrumbs e navegação Previous/Next
- Índices e roadmaps em cada nível

### ✅ **Reutilização**
- Templates modulares e parametrizáveis
- Scripts com convenções de nomenclatura claras
- Documentação com templates padronizados

## 🚀 Próximos Passos

1. **✅ CONCLUÍDO**: Estrutura de diretórios organizada
2. **✅ CONCLUÍDO**: Scripts movidos para `assets/scripts/`
3. **✅ CONCLUÍDO**: Templates organizados em `assets/templates/`
4. **✅ CONCLUÍDO**: Links atualizados para nova estrutura
5. **⏳ PENDENTE**: Validação completa de links
6. **⏳ PENDENTE**: Testes de navegação end-to-end
7. **⏳ PENDENTE**: População dos scripts específicos por horizon

## 📞 Localização dos Recursos

| Recurso | Localização | Propósito |
|---------|-------------|-----------|
| **Documentação** | `docs/` | Conteúdo organizado por horizon |
| **Diagramas** | `assets/diagrams/` | Arquivos SVG e Mermaid |  
| **Imagens** | `assets/images/` | Logos e recursos visuais |
| **Scripts H1** | `assets/scripts/h1-foundation/` | Automação foundation |
| **Scripts H2** | `assets/scripts/h2-optimization/` | Automação optimization |  
| **Scripts H3** | `assets/scripts/h3-innovation/` | Automação innovation |
| **Scripts Gerais** | `assets/scripts/shared/` | Utilitários comuns |
| **Templates Bicep** | `assets/templates/bicep/` | IaC Azure |
| **Templates CI/CD** | `assets/templates/github-actions/` | Workflows |
| **Templates K8s** | `assets/templates/helm-charts/` | Deployments |
| **Templates Docs** | `assets/templates/documentation/` | Padrões de documentação |

---

<div align="center">

**🎯 Estrutura Otimizada e Centralizada**

*Organização clara, navegação simples, reutilização eficiente*

</div>
