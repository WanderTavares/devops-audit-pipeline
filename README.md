# DevOps Audit Pipeline – Azure DevOps & Kubernetes

## Descrição do Projeto
Este projeto foi desenvolvido como parte de um desafio técnico para a posição de **DevOps Engineer**, com foco em **auditoria de pipelines**, **qualidade de código**, **segurança**, e **otimização de recursos em Kubernetes**, utilizando práticas modernas de CI/CD.

A solução foi projetada considerando **limitações de contas free**, priorizando **automação, arquitetura e boas práticas DevOps**.

---

## Objetivos
- Auditar e validar pipelines no Azure DevOps
- Garantir qualidade de código via SonarCloud
- Integrar testes de segurança dinâmica (DAST)
- Otimizar recursos em Kubernetes (HPA, CPU, Memória)
- Centralizar métricas, logs e alertas
- Gerar documentação e relatórios de auditoria

---

## Tecnologias Utilizadas
- **Azure DevOps Pipelines** (CI/CD)
- **SonarCloud** (Qualidade de Código)
- **OWASP ZAP** (DAST – abordagem teórica)
- **Kubernetes / AKS** (Infraestrutura como Código)
- **Shell Script / YAML**
- **Git** (Versionamento)

---

## Limitações Conhecidas
Devido ao uso de contas **free**, algumas funcionalidades foram **simuladas ou descritas teoricamente**, incluindo:
- Execução real de DAST em ambiente produtivo
- Coleta real de métricas via Azure Monitor
- Cluster AKS produtivo

Essas limitações **não comprometem o desenho da solução**, que segue padrões reais de ambientes corporativos.

---

## Estrutura do Repositório

├── azure-pipelines.yml # Pipeline CI/CD
├── k8s/ # Manifests Kubernetes (HPA, limits)
├── scripts/ # Scripts de auditoria e correção
├── security/ # DAST (simulado)
├── docs/ # Documentação e relatórios
└── README.md

---

## Documentação
A documentação detalhada está disponível no diretório `/docs`, incluindo:
- Arquitetura da pipeline
- Estratégia de segurança
- Otimizações em Kubernetes
- Relatório final de auditoria

---

## Autor
Wander Tavares  
DevOps Engineer
