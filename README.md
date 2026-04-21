# 🐍 Jogo Snake em Assembly MIPS

[![Linguagem](https://img.shields.io/badge/Linguagem-Assembly_MIPS-blue.svg)]()
[![Simulador](https://img.shields.io/badge/Simulador-MARS_4.5-orange.svg)]()
[![Status](https://img.shields.io/badge/Status-Prot%C3%B3tipo_Funcional-brightgreen.svg)]()

## 📌 Sobre o Projeto
Este projeto consiste no desenvolvimento do clássico jogo "Snake" (Jogo da Cobrinha) escrito inteiramente em linguagem de máquina (Assembly) para a arquitetura MIPS. O desenvolvimento faz parte das atividades da disciplina de **Arquitetura de Computadores (2026.1)** da **Universidade Federal do Maranhão (UFMA)**.

O objetivo principal é aplicar, na prática, os conceitos fundamentais da interação entre software e hardware, demonstrando o domínio sobre operações elementares da Unidade Central de Processamento (UCP), manipulação direta de memória e comunicação com dispositivos de Entrada e Saída.

## 🎯 Escopo
O projeto foi desenvolvido sob rigorosas limitações de baixo nível, incluindo:
* **Código 100% Assembly MIPS:** Sem uso de linguagens de alto nível (C, Python, Java).
* **Memory-Mapped I/O (E/S Mapeada em Memória):** Leitura de teclado via técnica de *Polling* e controle gráfico via acesso direto à memória.
* **Estrutura de Dados em Memória:** Gerenciamento do corpo da cobra utilizando arrays paralelos alocados estaticamente.
* **Otimização de ULA:** Uso de operações lógicas de deslocamento de bits (`sll`) no lugar de instruções de multiplicação tradicionais para otimizar os ciclos de clock durante a renderização gráfica.

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
   * Base address for display: `0x10040000 (heap)` **(Importante: O uso do segmento Data causará conflito de endereçamento)**
4. Conecte ambas as ferramentas clicando no botão **Connect to MIPS**.
5. Compile o código pressionando `F3`.
6. Execute o código pressionando `F5`.
7. **Controle:** Clique dentro da caixa de texto branca inferior do *Keyboard Simulator* e utilize as teclas `W`, `A`, `S` e `D` para movimentar a cobra.

## 🧠 Destaques Técnicos e Arquiteturais
* **Relação com o Modelo de Von Neumann (IAS):** O projeto ilustra perfeitamente o princípio do programa armazenado, onde instruções (`.text`) e dados (`.data`) compartilham o mesmo espaço lógico de endereçamento.
* **Prevenção de Colisões de I/O:** Durante o desenvolvimento, aplicamos o isolamento da memória de vídeo na área de *Heap* (`0x10040000`) para evitar o sobrescrito das variáveis de controle do jogo (endereçadas no *Data Segment*).
* **Geração Segura de Elementos:** O algoritmo de geração aleatória de "maçãs" (*syscall 42*) inclui um laço de validação para garantir que o alvo nunca seja gerado sobre as coordenadas atuais ocupadas pelo corpo da cobra.

## 👥 Equipe Desenvolvedora
* Alana Mayara Silva Monteiro
* Arthur Felipe Mourão de Oliveira
* Cássio Herberth Rodrigues Araújo
* Millena Gomes Andrade de Menezes Braga
* Stefany Costa de Almeida

**Professor Orientador:** Luiz Henrique Neves Rodrigues
