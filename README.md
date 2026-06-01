# 🐍 Jogo Snake em Assembly MIPS

[![Linguagem](https://img.shields.io/badge/Linguagem-Assembly_MIPS-blue.svg)]()
[![Simulador](https://img.shields.io/badge/Simulador-MARS_4.5-orange.svg)]()
[![Status](https://img.shields.io/badge/Status-Concluído-brightgreen.svg)]()

## 🚀 Status Atual: Versão Final (Atualizada)
O projeto superou com sucesso a fase de validação do núcleo principal e alcançou a sua versão final. O protótipo base foi expandido, otimizado e integrado com múltiplos periféricos do simulador MARS, garantindo uma aplicação direta do modelo clássico de Von Neumann e uma manipulação de hardware de baixo nível totalmente funcional e estável.

### ✨ Novas Funcionalidades e Atualizações Implementadas
* **Expansão da Arena (64x64):** A matriz de endereçamento lógico foi dobrada, aumentando significativamente a área jogável e a resolução da tela.
* **Placar via Hardware (Display de 7 Segmentos):** Implementação de pontuação em tempo real utilizando MMIO para separar dezenas e unidades, enviando sinais elétricos diretos aos displays esquerdos e direitos.
* **Áudio Nativo MIDI:** Integração de chamadas de sistema para gerar efeitos sonoros:
  * *Syscall 31 (Assíncrono):* Som de captura da maçã sem interromper o *Game Loop*.
  * *Syscall 33 (Síncrono):* Som de "Game Over" bloqueando a execução da UCP.
* **Mapeamento Redundante de Teclado:** Suporte simultâneo para três padrões de controle visando contornar a limitação de *KeyEvents* do simulador: Padrão `W A S D` (mão esquerda), `I J K L` (mão direita) e **Teclado Numérico `8 4 2 6`** (simulando setas).
* **Depuração Visual:** Resolução de anomalias de memória (*bugs*), como o "pixel fantasma" na cauda da cobra e a sobrescrita do quadrante `(0,0)` no momento da pontuação.

---

## 📁 Estrutura do Repositório
O projeto está organizado da seguinte forma para facilitar a navegação e avaliação:

- 📂 **`src/`** (Código-fonte)
  - 📜 Contém o arquivo principal do jogo em Assembly MIPS (`.asm`).
- 📂 **`docs/`** (Documentação e Relatórios)
  - 📄 Relatórios técnicos de atualização.
  - 📊 Gráfico de Gantt (Cronograma).
- 📂 **`media/`** (Vídeos e Testes)
  - 🎥 Demonstrações de execução do jogo.

---

## 📌 Sobre o Projeto
Este projeto consiste no desenvolvimento do clássico jogo "Snake" (Jogo da Cobrinha) escrito inteiramente em linguagem de máquina (Assembly) para a arquitetura MIPS. O desenvolvimento faz parte das atividades da disciplina de **Arquitetura de Computadores (2026.1)** da **Universidade Federal do Maranhão (UFMA)**.

O objetivo principal é aplicar, na prática, os conceitos fundamentais da interação entre software e hardware, demonstrando o domínio sobre operações elementares da Unidade Central de Processamento (UCP), manipulação direta de memória e comunicação com dispositivos de Entrada e Saída.

## 🎯 Escopo e Destaques Técnicos (Core Engine)
O núcleo do jogo foi desenvolvido sob rigorosas limitações de baixo nível:
* **Código 100% Assembly MIPS:** Sem uso de abstrações ou linguagens de alto nível (C, Python, Java).
* **Memory-Mapped I/O (MMIO):** Leitura de teclado via técnica de *Polling* assíncrono (`0xFFFF0000`) e controle gráfico via acesso direto à memória.
* **Estrutura de Dados:** Gerenciamento do corpo da cobra utilizando arrays paralelos alocados estaticamente na seção `.data`.
* **Isolamento de Memória:** O *Bitmap Display* foi alocado de forma isolada na área de *Heap* (`0x10040000`) para evitar a sobrescrita das variáveis de controle do jogo (resolvendo o conflito de *Address out of range*).
* **Otimização de ULA:** Uso de operações lógicas de deslocamento de bits (`sll`) para otimizar o cálculo matemático de endereçamento dos pixels na matriz gráfica.

## ⚠️ Limitações Técnicas e Decisões Arquiteturais
Durante o desenvolvimento, duas limitações de hardware/software do simulador MARS foram identificadas e contornadas com decisões de engenharia:

* **O Problema das Setas Direcionais:** A ferramenta de entrada (MMIO) do MARS foi programada sobre um campo de texto Java. Teclas direcionais físicas (setas) não geram caracteres ASCII de 1 byte; elas apenas movem o cursor do mouse no sistema operacional. Logo, elas não enviam sinais elétricos para o registrador de dados (`0xFFFF0004`), deixando o processador "cego" para essas teclas. **Solução:** Aplicamos redundância de software mapeando o Teclado Numérico (8, 4, 2, 6) e as teclas `I J K L`, que geram códigos ASCII válidos e entregam a mesma experiência tátil em formato de cruz.
* **O Limite de Expansão Gráfica (Tela):** A tela foi expandida com segurança até 512x512 pixels (arena lógica de 64x64). Aumentar a escala além desse limite causa sobrecarga gráfica catastrófica. Como o MARS roda sobre a Máquina Virtual Java (JVM), forçar a renderização de resoluções massivas (ex: 1024x1024) pixel a pixel gera um gargalo de processamento. Isso resulta em *lag* severo, travamento total da CPU virtual e erros fatais de limite de memória (*Address out of range*). O limite atual estabelecido garante máxima estabilidade e fluidez.

## ⚙️ Como Executar (Configuração do MARS 4.5)
Para rodar a versão atualizada do jogo, é necessário utilizar o simulador **MARS (MIPS Assembler and Runtime Simulator) versão 4.5**.

1. Clone o repositório e abra o arquivo principal `.asm` (localizado na pasta `src/`) no MARS 4.5.
2. Acesse o menu **Tools** e abra as seguintes ferramentas:
   * **Bitmap Display**
   * **Keyboard and Display MMIO Simulator**
3. Configure o **Bitmap Display** estritamente com os seguintes parâmetros para suportar a nova arena com estabilidade:
   * Unit Width in Pixels: `8`
   * Unit Height in Pixels: `8`
   * Display Width in Pixels: `512` *(Tela expandida)*
   * Display Height in Pixels: `512` *(Tela expandida)*
   * Base address for display: `0x10040000 (heap)` 
4. Conecte ambas as ferramentas clicando no botão **Connect to MIPS**.
5. Compile o código pressionando `F3`.
6. Execute o código pressionando `F5`.
7. **Controles:** Clique dentro da caixa de texto branca inferior do *Keyboard Simulator* e utilize as teclas `WASD`, `IJKL` ou o **Numpad (8,4,2,6)** para movimentar a cobra.

## 🤖 Metodologia: Apoio de Inteligência Artificial
Com o intuito de maximizar o aprendizado e adotar práticas modernas de engenharia de software, a equipe utilizou ferramentas de Inteligência Artificial Generativa (LLMs) como apoio metodológico auxiliar. O uso restringiu-se ao esclarecimento de conceitos arquiteturais de baixo nível, suporte no diagnóstico de conflitos de endereçamento de memória e revisão da documentação técnica, preservando a autoria humana em toda a lógica e tomada de decisão do projeto.

## 👥 Equipe Desenvolvedora
* Alana Mayara Silva Monteiro
* Arthur Felipe Mourão de Oliveira
* Cássio Herberth Rodrigues Araújo
* Millena Gomes Andrade de Menezes Braga

**Professor Orientador:** Luiz Henrique Neves Rodrigues
