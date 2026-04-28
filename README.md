# 🐍 Jogo Snake em Assembly MIPS

[![Linguagem](https://img.shields.io/badge/Linguagem-Assembly_MIPS-blue.svg)]()
[![Simulador](https://img.shields.io/badge/Simulador-MARS_4.5-orange.svg)]()
[![Status](https://img.shields.io/badge/Status-Fase_de_Testes_(Adiantado)-brightgreen.svg)]()

## 📌 Sobre o Projeto
Este projeto consiste no desenvolvimento do clássico jogo "Snake" (Jogo da Cobrinha) escrito inteiramente em linguagem de máquina (Assembly) para a arquitetura MIPS. O desenvolvimento faz parte das atividades da disciplina de **Arquitetura de Computadores (2026.1)** da **Universidade Federal do Maranhão (UFMA)**.

O objetivo principal é aplicar, na prática, os conceitos fundamentais da interação entre software e hardware (baseado no modelo de Von Neumann), demonstrando o domínio sobre operações elementares da Unidade Central de Processamento (UCP), manipulação direta de memória e comunicação com dispositivos de Entrada e Saída.

## 🎯 Escopo e Destaques Técnicos
O projeto foi desenvolvido sob rigorosas limitações de baixo nível:
* **Código 100% Assembly MIPS:** Sem uso de linguagens de alto nível (C, Python, Java).
* **Memory-Mapped I/O (MMIO):** Leitura de teclado via técnica de *Polling* (`0xFFFF0000`) e controle gráfico via acesso direto à memória.
* **Estrutura de Dados:** Gerenciamento do corpo da cobra utilizando arrays paralelos alocados estaticamente na seção `.data`.
* **Isolamento de Memória:** O *Bitmap Display* foi alocado na área de *Heap* (`0x10040000`) para evitar o sobrescrito das variáveis de controle do jogo (resolução de *Address out of range*).
* **Otimização de ULA:** Uso de operações lógicas de deslocamento de bits (`sll`) para otimizar o cálculo de endereçamento dos pixels na tela.

## 📊 Gestão do Projeto
O desenvolvimento foi guiado por um planejamento rigoroso (TAP), garantindo que o escopo fosse mantido. 
* Utilizamos o **Gráfico de Gantt** para o controle do cronograma macro e o **Painel Kanban** para o fluxo ágil de tarefas. 
* Devido à divisão eficiente de funções, a equipe antecipou a integração do motor gráfico e do *Game Loop*, alcançando um protótipo funcional ainda em meados de abril, liberando as semanas seguintes para testes e otimização.

*A documentação completa, cronogramas e relatórios encontram-se nos PDFs anexados a este repositório.*

## ⚙️ Como Executar (Configuração do MARS 4.5)
Para rodar o jogo, é necessário utilizar o simulador **MARS (MIPS Assembler and Runtime Simulator) versão 4.5**.

1. Abra o arquivo `snake.asm` no MARS 4.5.
2. Acesse o menu **Tools** e abra as seguintes ferramentas:
   * **Bitmap Display**
   * **Keyboard and Display MMIO Simulator**
3. Configure o **Bitmap Display** estritamente com os seguintes parâmetros:
   * Unit Width in Pixels: `8`
   * Unit Height in Pixels: `8`
   * Display Width in Pixels: `256`
   * Display Height in Pixels: `256`
   * Base address for display: `0x10040000 (heap)` 
4. Conecte ambas as ferramentas clicando no botão **Connect to MIPS**.
5. Compile o código pressionando `F3`.
6. Execute o código pressionando `F5`.
7. **Controles:** Clique dentro da caixa de texto branca inferior do *Keyboard Simulator* e utilize as teclas `W`, `A`, `S` e `D` para movimentar a cobra.

## 🤖 Metodologia: Apoio de Inteligência Artificial
Com o intuito de maximizar o aprendizado e adotar práticas modernas de engenharia de software, a equipe utilizou ferramentas de Inteligência Artificial Generativa (LLMs) como apoio metodológico. O uso focou-se no esclarecimento de conceitos arquiteturais de baixo nível, suporte na depuração de conflitos de endereçamento e formatação da documentação técnica e cronogramas, atuando como um acelerador produtivo.

## 👥 Equipe Desenvolvedora
* Alana Mayara Silva Monteiro
* Arthur Felipe Mourão de Oliveira
* Cássio Herberth Rodrigues Araújo
* Millena Gomes Andrade de Menezes Braga
* Stefany Costa de Almeida

**Professor Orientador:** Luiz Henrique Neves Rodrigues
