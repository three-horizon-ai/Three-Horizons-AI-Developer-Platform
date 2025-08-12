# Three Horizons AI Developer Platform - Dev Box Template

Este arquivo `imageDefinition.yaml` define um template de Dev Box customizado para o projeto Three Horizons AI Developer Platform, projetado para ser usado com o Red Hat Developer Hub.

## 📋 Ferramentas Incluídas

### Ferramentas de Desenvolvimento Essenciais
- **Azure Developer CLI (azd)** - Para deployment e gerenciamento de recursos Azure
- **Visual Studio Code** - IDE principal com extensões específicas
- **Node.js LTS** - Para aplicações JavaScript/TypeScript 
- **Python 3.11** - Para scripts e aplicações AI/ML
- **Docker Desktop** - Para containerização
- **Git** - Controle de versão
- **PowerShell Core** - Shell avançado

### Ferramentas Azure e Cloud
- **Azure CLI** - Gerenciamento de recursos Azure
- **Terraform** - Infrastructure as Code
- **GitHub CLI** - Integração com GitHub

### Extensões VS Code Pré-instaladas
- **Python** - Suporte completo para Python
- **Azure Functions** - Desenvolvimento de Azure Functions
- **Jupyter** - Notebooks para AI/ML
- **Azure CLI** - Integração com Azure CLI
- **Bicep** - Azure Resource Manager templates
- **YAML** - Suporte para arquivos YAML
- **GitHub Copilot** - AI-powered coding assistant
- **C#** - Suporte para .NET development

## 🚀 Funcionalidades

### Configuração Automática
1. **Clone do Repositório**: Automaticamente clona o repositório do projeto em `C:\Workspaces`
2. **Extensões VS Code**: Instala todas as extensões necessárias para desenvolvimento
3. **Ambiente Preparado**: Todas as ferramentas essenciais instaladas e configuradas

## 📁 Estrutura do Projeto

O Dev Box será configurado com:
```
C:\Workspaces\Three-Horizons-AI-Developer-Platform\
├── templates/
│   ├── h0-devbox/          # Templates de Dev Box
│   ├── h1-foundation/      # Templates básicos
│   ├── h2-optimization/    # Templates avançados
│   └── h3-innovation/      # Templates inovadores
├── docs/                   # Documentação completa
├── scripts/               # Scripts de automação
└── resources/             # Recursos Azure (Bicep/Terraform)
```

## 🔧 Como Usar

### 1. Provisionar no Azure Dev Box
1. Vá para o [portal Azure](https://portal.azure.com)
2. Navegue para **Dev Box** > **Image Definitions**
3. Crie uma nova definição de imagem
4. Upload este arquivo `imageDefinition.yaml`
5. Configure um pool de Dev Box usando esta imagem

### 2. Integrar com Red Hat Developer Hub

#### No Software Template (template.yaml):
```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: three-horizons-devbox
  title: Three Horizons AI Developer Platform Dev Box
  description: Dev Box pré-configurado para desenvolvimento AI/Azure
spec:
  owner: platform-team
  type: development-environment
  parameters:
    - title: Dev Box Configuration
      properties:
        projectName:
          title: Nome do Projeto
          type: string
        devBoxSize:
          title: Tamanho do Dev Box
          type: string
          enum:
            - "Standard_D4as_v4"
            - "Standard_D8as_v4"
            - "Standard_D16as_v4"
  steps:
    - id: provision-devbox
      name: Provisionar Dev Box
      action: azure:devbox:create
      input:
        imageDefinition: three-horizons-ai-devbox
        projectName: ${{ parameters.projectName }}
        size: ${{ parameters.devBoxSize }}
```

### 3. Validação
Para validar este template em um ambiente Dev Box, execute:
```powershell
devbox customizations validate-tasks --filePath "imageDefinition.yaml"
```

## 📚 Documentação Oficial

Para mais informações sobre customizações de Dev Box, visite:
- [Documentação oficial Azure Dev Box](https://learn.microsoft.com/en-us/azure/dev-box/concept-what-are-team-customizations)
- [Red Hat Developer Hub Templates](https://docs.redhat.com/en/documentation/red_hat_developer_hub)

## 🎯 Próximos Passos

1. **Provisionar recursos Azure**: Use os templates em `/resources/bicep/`
2. **Explorar templates**: Comece com templates em `/templates/h1-foundation/`
3. **Seguir guias**: Consulte `/docs/guides/` para tutoriais detalhados
4. **Configurar CI/CD**: Use os workflows em `.github/workflows/`

## 🆘 Suporte

Para suporte ou questões:
- Consulte a documentação em `/docs/`
- Abra uma issue no repositório GitHub
- Entre em contato com a equipe de plataforma
