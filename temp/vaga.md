# Desafio

- Budget
- Azure
- AzureDevOps

Tenho um budget, tenho uma ideia de um banco e um app, objetivo ser o maior banco consignado do Brasil.

Preciso de um site para pré-cadastro dos meus futuros clientes, para saber informações sobre renda, convenios e informações gerais para que eu possa filtrar futuramente para poder endereçar os dados para que o Marketing consiga fazer o trabalho de forma eficiente e eficaz.


## Eu quero que você desenhe a melhor solução para me atender.

- Estrutura
- Redes/Segmentação de rede
- Segurança
- Acesso a Azure
- Acesso ao AzureDevOps
- Implementação da solução
  - Micro-serviços ?
    - Implementação
  - Serviço legado ?
    - Implementação
- Troubleshooting


## Cenário de Troubleshooting

Hoje eu fiz uma campanha no intervalo do jornal nacional, e o site começou a ter um load alto devido a quantidade de novas requisições no frontend da solução.
- Quero a sua análise de como resolver o problema
  - Análise do SO
  - Análise da solução web para prover acesso as novas requisições
    - Load de processamento esta alto e memoria baixa.
    - Load de processamento baixo e memoria alta.
    - Procedimento para resolver a solução, aumentar threads, tunning de memoria. (Como abordar um reinicio sem perder as conexões correntes.)
  - Análise da solução de banco de dados.
  - Se a solução for web via app service -> up to 20 instances (Premium V2) R$ 328,10 por instancia.


## Cenário montar Estrutura do SO para cada solução.

- Particionamento da solução (melhor divisão para um determinado disco)
- Melhorar a performace dos discos (Sistemas de arquivo/Meio de acesso)

## Cenário demanda aumentou
- Como suportar via Azure/Micro-serviços

## Cenário trafego alto
- Fizemos um campanha em todos os jornais da amarica latina quero expandir o meu alcance desta forma o trafego esta muito alto, as requisições dos meus clientes esão lentas para processar, eu preciso de uma solução urgente estou perdendo de ganhar dinheiro.
- Trafego alto + Alta demanda + (limite de budget no acabou)
- Preciso liberar um trafego maior no proximo mês já que a demanda aumentou consideravelmente.
- Liberar o trafego de frontend via (XXX)

- Analise do Cenário
- Web Api -> Aguenta o fluxo, precisa de mais instancias, a configuração do pod, container, serviço esta correta ?
- Banco de dados -> Aguenta o fluxo, precisa de mais instancias ? tem replicas, serviço do tipo SAAS ? PAAS ?


### Arquitetura de CI/CD

Agora preciso da seguinte solução

Eu sou o desenvolvedor acabei de terminar a minha solução, já fiz os meus unit tests e preciso publicar a minha aplicação.

Como deve ser o processo ?
- Definir Dockerfile
- Definir Build
- Processo da Build
- Trigger por Branches ?
- Politicas de Branch
  - Todos podem efetuar commit na branch master ?
  - Tem pessoas para revisarem o código
  - Passou pela esteira de code coverage ?
  - Passou pela esteira de segurança ?
  - Configurado o pull-request ?
- Aonde vou armazenar os dados (artefatos, imagens)
- Definir a esteira de deploy
- Etapas
- Varios ambientes como dividir o deploy ?
- Porque foi dividido da forma proposta ?
- Tipos de backend para receber o deploy
- App Service
- Kubernetes
- Service Fabric
- Docker
- Docker Swarm

## Troubleshooting de Kubernetes
- Me explique a estrutura do Kubernetes
- Me explique a estrutura de um deploy no Kubernetes
- Fluxo
  - scheduler
  - work node
  - deployment
  - replicaset
  - pods
    - service
    - routes/ingress
      - modos de controle
- Minha solução não está subindo.
  - Pod com status de pending
  - Pod com status de error
  - Pod com status de errorconfig
- Meu pod subiu, o service subiu porém não consigo acessar o serviço
  - Como testar o serviço
  - Como saber se tenho pods neste serviço
  - Como atribuir pods ao serviço
- Meu pod subiu porém reinicia a cada 120 segundos
  - O que pode estar acontecendo ?
  - Como efetuar o Troubleshooting
- Meu pod subiu porém nao consigo acessar o serviço
  - O meu pod não esta registrado como endpoint
  - Quais os possiveis motivos ?
    - liveness, readiness
      - explicar os conceitos
- Atribui uma quota de 2 cores para o meu pod o meu cluster tem 48 vcores e o meu pod não sobe
  - Qual o possivel motivo
- Atribui uma quota de 50m de vcpu para o meu pod e ele não sobe
  - Qual o possivel motivo
- Subi um pod com o MariaDB crei alguns bancos de dados e tabelas e liberei para a minha aplicação, porém após alguns dias eu deletei o pod, quando subi o pod novamente não tinha mais os meus dados.
  - Qual o motivo de não existirem mais os dados
  - Como abordar este tipo de situação
- Me explique quando devo utiliar configmap e quanto utilizar secrets
  - Qual a diferença
  - Como posso fazer a utilização deles
  - Como posso consumir os dados nos pods ?


## Definição de yaml
- Como devem ser identadas as linhas?
- Definição de listas
- separação entre recursos ex: deployment, service, route no mesmo arquivo.
- Definição de uma variável do tipo texto para replace, processamento
- Definição de uma variável do tipo inteiro para replace, processamento

## Definição de DNS
- Como funciona o protocolo
- Tipos de registros
- Tipos de zonas utilizadas pela azure ?

## SSL
- Definição
- Tipos de certificados para Web Sites, Applications


## Preciso de um desenho para atender a seguinte situação.

- Tenho um App que precisa ser consumido de fora da minha rede
- App esta dentro de um servidor Kubernetes
- Não quero que tenham ciencia do meu verdadeiro endereço dns de acesso
- Preciso que as minhas replicas da aplicação sejam divididas
- Preciso da segurança que somente conexões vindas de uma determinada origem sejam aceitas


## AzureDevOps
- Controle de serviços que preciso acessar
- Controle de acesso
- Controle de Branches
- controle de variáveis
  - Como fazer o controle
  - Como aplicar elas em build e deploy
- Controle de triggers
- Filtragem de artefatos
- Controle do modelo de deploy para varios ambientes


## Terraform
- Definição
- Aplicação
- Interpolação
- Como trabalhar com variaveis
- Reaproveitamento de variaveis por recursos
  - Como se referenciar ao nome do resource group criado randomicamente para utilizar na criação dos recursos filhos.


## Ansible
- Definição
- Criação de roles
- Modo de trabalho
- Ambientes
- Formatos de execução.

## Documentação
- Quando você recebe uma task que não existe documentação, como é a sua abordagem
- Quando você recebe uma task que já está documentada e precisa atualizar ?
  - Existem outros recursos que vão precisar dessa documentação antiga, todos os sistemas já abordam o novo modelo ?

## Programação
- ShellScript
- Python
- DotNet
- NodeJS
- Java

## Monitoramento
- Zabbix
- Grafana
- Prometheus
- Node_exporter
- Apis

## Logs
- elasticsearch
- logstash
- fluentd
- kibana

## Methodos HTTP
- Definição
- Diferença entre POST/GET

## Bancos de dados
- MySQL
- MariaDB
- PostgreSQL
- SQL Server

## Questões
- Como você reage a um feedback
- Exemplo de um feedback que você recebeu e não gostou
- Como você aborda alguém para dar um feedback ?


