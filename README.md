# 🐍 Projeto Snake: MIPS Assembly & Integração Web

**Universidade Federal do Maranhão (UFMA)**
**Disciplina:** Arquitetura de Computadores
**Curso:** Bacharelado Interdisciplinar em Ciência e Tecnologia

---

## 📌 Visão Geral do Projeto
Este repositório contém a versão final e consolidada do jogo "Snake", programado integralmente em linguagem de baixo nível (**MIPS Assembly**) utilizando o simulador MARS. 

O projeto transcende a lógica básica de jogos em terminal, operando como um estudo de caso complexo de Arquitetura de Sistemas. A solução implementa otimização de ciclos de processamento na ULA, controle físico de memória e uma ponte assíncrona (*Middleware*) que conecta o hardware simulado a um Dashboard Web moderno de *High Scores*.

## 🚀 Principais Tecnologias e Arquitetura

* **Linguagem:** Assembly MIPS (Padrão RISC)
* **Ambiente de Simulação:** MARS (MIPS Assembler and Runtime Simulator)
* **Controle de Periféricos:** MMIO (Memory-Mapped I/O) para Teclado, Bitmap Display de 64x64 e Displays de 7 Segmentos.
* **Integração Front-end:** HTML5, CSS3 e JavaScript (Vanilla) com Fetch API assíncrona.

## 🧠 Destaques de Engenharia

1. **Otimização de Hardware (Bitwise):** Substituição da instrução nativa de multiplicação (`mult`) por Deslocamento Lógico à Esquerda (`sll`), reduzindo o custo computacional de cálculo de matrizes de vídeo para apenas 1 ciclo de *clock*.
2. **Gestão Segura de Memória:** Alocação estática e rigorosa da seção `.data` (`.space 16384`) para mapear vetorialmente o corpo da cobra sem causar invasão de endereços ou *Stack Overflow*.
3. **Middleware Cross-Layer:** Sistema de *Polling* assíncrono em JavaScript que monitora as Syscalls do MIPS gravadas no disco operacional, traduzindo o binário em arquitetura *Little-Endian* diretamente para a interface do navegador em tempo real.

## 📺 Demonstração e Documentação

* Consulte o [Relatório Técnico Final] e os [Slides da Apresentação] na raiz deste repositório para detalhes aprofundados sobre a arquitetura e a resolução de gargalos operacionais.
* **Vídeo de Funcionamento:** [Insira o link do seu Google Drive aqui]

## 👨‍💻 Equipe Desenvolvedora

* Alana Mayara Silva Monteiro
* Arthur Felipe Mourão de Oliveira
* Cássio Herberth Rodrigues Araújo
* Millena Gomes Andrade de Menezes Braga
