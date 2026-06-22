# arrumaÍF

> Sejam bem vindos ao arrumaÍF, o Sistema de reportes em reparos do IFSP - Bragança Paulista

## 📌 O que é o arrumaÍF

O arrumaíF é um sistema web e mobile desenvolvido para suprir a falta de 
um canal oficial no IFSP-BRA que dê autonomia para alunos, professores e 
servidores reportarem defeitos e problemas em equipamentos e mobiliários 
no cotidiano do campus. O sistema centraliza os reportes, agiliza a 
providência de reparos pela equipe de manutenção e estabelece um fluxo 
transparente de comunicação.

## 🚦 Status

<img src="https://img.shields.io/badge/version-2.0.0-blue" alt="version" /> <img src="https://img.shields.io/badge/status-em%20desenvolvimento-yellow" alt="status" />

## 🛣️ Roadmap

- [ ✅ ] Especifiação Funcional 
- [ ✅ ] Protótipos de Telas
- [ ✅ ] Schema Banco de Dados
- [ ✅ ] API Backend
- [ ✅ ] Front-End
- [ ✅ ] Aplicativo Mobile 


## 🎯 Objetivos

- Centralizar a criação e oficialização de reportes de manutenção em 
  uma única ferramenta.
- Agilizar a identificação, localização e solução de problemas por parte 
  da equipe de mantenedores.
- Garantir transparência permitindo que os autores dos reportes acompanhem em tempo real o status dos equipamentos afetados.
- Promover melhores interações entre atores da instituição, acolhimento de frustrações, e, consequentemente, melhorar a qualidade de ensino dos alunos.

## 🧩 Problemas que o arrumaÍF atende

Atualmente, a alta rotação de pessoas no campus gera desgastes e defeitos 
em equipamentos e salas de aula. A ausência de um canal oficial gera 
processos longos e burocráticos de reporte (exigindo intermediação de 
professores via e-mails sem respostas rápidas), causando estresse, 
atrasos crônicos na manutenção e falta de visibilidade sobre o andamento 
dos consertos.

## 💡 Solução Proposta

- Um sistema multiplataforma (Web e Mobile) baseado no modelo cliente-servidor. 
Ele permite que a comunidade acadêmica registre chamados de falhas de 
infraestrutura em poucos passos (selecionando bloco/sala, tipo de material 
e defeito), gerando um histórico público de auditoria imutável e permitindo 
contestações caso o problema persista.

## ✅ Funcionalidades
<table>
    <thead>
        <tr>
            <th>ID</th>
            <th>Descrição</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>RF01</td>
            <td>Registro de Solicitação: Criação e edição de chamados especificando o Equipamento/Mobiliário, Tipo do Defeito e Descrição opcional.</td>
        </tr>
        <tr>
            <td>RF02</td>
            <td>Consulta de Solicitações: Visualização da listagem de chamados criados pelo usuário com status e histórico cronológico.</td>
        </tr>
        <tr>
            <td>RF03</td>
            <td>Gestão de Status: Alteração controlada do ciclo de vida do chamado pela equipe técnica.</td>
        </tr>
        <tr>
            <td>RF04</td>
            <td>Encerramento com Diagnóstico: Obrigatoriedade de preenchimento dos campos técnicos de Causa e Solução ao finalizar um chamado.</td>
        </tr>
        <tr>
            <td>RF05</td>
            <td>Contestação de Resolução: Permite reabrir a discussão caso o reparo não atinja o resultado esperado.</td>
        </tr>
        <tr>
            <td>RF06</td>
            <td>Log de Auditoria: Registro automatizado, sistêmico e imutável de cada transição de status.</td>
        </tr>
        <tr>
            <td>RF07</td>
            <td>Anexo de Fotos na Solicitação: Anexo que auxilia na visualização e entendimento da demanda, agilizando o reparo.</td>
        </tr>
    </tbody>
</table>

<!-- ## 🖼️ Demonstração

- [Espaço para imagens, GIFs ou links de vídeo]
- [Exemplo de uso ou fluxo visual] -->

## 🧰 Tecnologias Utilizadas

<table>
    <thead>
        <tr>
            <th>Tecnologia</th>
            <th>Uso no Projeto</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><img src="https://img.shields.io/badge/Figma-F24E1E?logo=figma&logoColor=white" alt="Figma" /> </td>
            <td>Ferramenta utilizada para prototipação e design das interfaces do sistema. Permite a criação de componentes reutilizáveis, definição de fluxos de navegação, validação de ideias e simulação da experiência do usuário antes da implementação.</td>
        </tr>
        <tr>
            <td><img src="https://img.shields.io/badge/React-20232A?logo=react&logoColor=61DAFB" alt="React" /></td>
            <td>Utilizado no desenvolvimento da interface web, adotando uma arquitetura baseada em componentes reutilizáveis. Proporciona maior organização do código, facilidade de manutenção e suporte à construção de interfaces responsivas e escaláveis.</td>
        </tr>
        <tr>
            <td><img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter" /></td>
            <td>Utilizado no desenvolvimento da aplicação mobile multiplataforma, permitindo a criação de uma única base de código para dispositivos Android e iOS. Sua arquitetura baseada em widgets facilita a reutilização de componentes e garante uma experiência consistente entre plataformas.</td>
        </tr>
        <tr>
            <td><img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python" /></td>
            <td>Linguagem utilizada no desenvolvimento do backend devido à sua simplicidade, produtividade e ampla adoção pela comunidade. Com o auxílio do microframework <img src="https://img.shields.io/badge/Flask-000000?logo=flask&logoColor=white" alt="Flask" />, foi desenvolvida uma API REST responsável por intermediar a comunicação entre as aplicações cliente e o banco de dados, além de gerenciar regras de negócio e autenticação.</td>
        </tr>
        <tr>
            <td><img src="https://img.shields.io/badge/Supabase-3ECF8E?logo=supabase&logoColor=white" alt="Supabase" /> </td>
            <td>Plataforma utilizada para hospedagem e gerenciamento do banco de dados PostgreSQL, fornecendo recursos de armazenamento, autenticação e integração com a aplicação. Sua infraestrutura gerenciada simplifica a configuração do ambiente e acelera o desenvolvimento do projeto.</td>
        </tr>
    </tbody>
</table>

## 🏗️ Arquitetura do Sistema

A aplicação adota o modelo Cliente-Servidor dividido logicamente em 
três camadas:
1. Camada de Apresentação (Client Side): Interfaces Web (React) e Mobile nativa (Flutter) que fazem requisições HTTP (REST/JSON).
2. Camada de Negócio / Serviços (Server Side): API Flask (Python) 
   centralizando o processamento, roteamento, validação e orquestração de regras.
3. Camada de Dados (Persistência): Ecossistema Supabase operando o 
   PostgreSQL (substituindo a intenção inicial do MySQL), além de 
   microsserviços nativos de Autenticação (Auth) e Armazenamento 
   de mídia (Storage).

<!-- ## 📊 Modelagem e Diagramas

- [Incluir modelo conceitual, diagramas de arquitetura, ERD, fluxos, etc.]

## 📚 Documentação da API

- [Link ou seção para endpoints disponíveis]
- [Formato de requisição e resposta]
- [Autenticação, headers e exemplos]

## 🤝 Como Contribuir

- [Instruções para abrir issues]
- [Guia para pull requests]
- [Padrões de revisão e comunicação] -->

## 🚀 Como Executar o Projeto

### Pré-requisitos
Antes de começar, você precisará ter instalado em sua máquina:
1. Flutter SDK (Versão estável atualizada).
2. Dart SDK (Incluído nativamente junto com o Flutter).
3. Um emulador configurado (Android Studio ou Xcode) ou um dispositivo físico conectado com a depuração USB ativada.

### Passo a Passo

1. Clonar o repositório:
   git clone https://github.com/seu-usuario/arrumaif-mobile.git
   cd arrumaif-mobile

2. Instalar as dependências do projeto:
   flutter pub get

3. Configurar as variáveis de ambiente:
   Crie um arquivo chamado .env na raiz do projeto com as credenciais ou URLs de API necessárias baseando-se no projeto do ecossistema arrumaÍF.

4. Executar a aplicação:
   flutter run

---

## 🤝 Como Contribuir

1. Faça um Fork do projeto.
2. Crie uma nova Branch para a sua funcionalidade (git checkout -b feature/NovaFuncionalidade).
3. Faça o Commit das suas alterações (git commit -m 'Adiciona nova funcionalidade').
4. Envie o código para a sua Branch (git push origin feature/NovaFuncionalidade).
5. Abra um Pull Request para análise.

---


## 👥 Colaboradores

<table align="center" cellpadding="10" cellspacing="0">
    <tr>
        <td align="center">
            <a href="https://www.linkedin.com/in/david-nascimento-7a2288218/">
                <img src="https://github.com/davenasc.png" width="100px" alt="" /><br />
                <sub><b>David Nascimento</b></sub>
            </a>
            <br />
            <sub><b>Dev Mobile & QA</b></sub>
        </td>
        <td align="center">
            <a href="https://www.linkedin.com/in/giovanni-alves-medici/">
                <img src="https://github.com/Giovanni-Alves-Medici.png" width="100px" alt="" /><br />
                <sub><b>Giovanni Alves Medici</b></sub>
            </a>
            <br />
            <sub><b>Product Owner & UX/UI</b></sub>
        </td>
        <td align="center">
            <a href="https://www.linkedin.com/in/kevin-bulunu-mukanda-49ab89271/">
                <img src="https://github.com/KevinPrince2024.png" width="100px" alt="" /><br />
                <sub><b>Kevin Bulunu</b></sub>
            </a>
            <br />
            <sub><b>Dev Mobile</b></sub>
        </td>
        <td align="center">
            <a href="https://www.linkedin.com/in/gaspar-jos%C3%A9-da-silva-763280289/">
                <img src="https://github.com/gaspardasilva12.png" width="100px" alt="" /><br />
                <sub><b>Gaspar José</b></sub>
            </a>
            <br />
            <sub><b>Dev Mobile</b></sub>
        </td>
        <td align="center">
            <a href="https://www.linkedin.com/in/galasso-matheus">
                <img src="https://github.com/Gatasso.png" width="100px" alt="" /><br />
                <sub><b>Matheus Galasso Romera</b></sub>
            </a>
            <br />
            <sub><b>Product Owner & Backend</b></sub>
        </td>
        <td align="center">
            <a href="https://www.linkedin.com/in/pedro-do-prado-hardmann-3b694828a/">
                <img src="https://github.com/PedroDoPrado.png" width="100px" alt="" /><br />
                <sub><b>Pedro Hardmann</b></sub>
            </a>
            <br />
            <sub><b>Dev Mobile</b></sub>
        </td>
    </tr>
</table>

<!-- ## 📄 Licença

- [Tipo de licença open source]
- [Link para o arquivo de licença] -->

