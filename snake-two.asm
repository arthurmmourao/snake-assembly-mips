# =============================================================================
# GLOSSARIO DE INSTRUCOES MIPS:
# lw   : Load Word (Carrega 4 bytes da memoria para um registrador)
# sw   : Store Word (Salva 4 bytes do registrador na memoria)
# li   : Load Immediate (Carrega um valor constante direto no registrador)
# la   : Load Address (Carrega o endereço de memória de uma variável/rótulo)
# add  : Soma dois registradores
# addi : Soma um registrador com uma constante (Immediate)
# sub  : Subtração
# sll  : Shift Left Logical (Desloca bits à esquerda = Multiplica por potências de 2)
# beq  : Branch if Equal (Desvio condicional: pula se valores forem iguais)
# bne  : Branch if Not Equal (Desvio condicional: pula se valores forem diferentes)
# bge  : Branch if Greater or Equal (Pula se maior ou igual)
# bltz : Branch if Less Than Zero (Pula se menor que zero)
# j    : Jump (Salto incondicional para um rótulo)
# jal  : Jump and Link (Salta para sub-rotina e salva o endereço de retorno)
# jr   : Jump Register (Retorna de uma sub-rotina usando o registrador $ra)
# div  : Divisão (Quociente vai para 'lo', resto para 'hi')
# mflo : Move from LO (Move o quociente da divisÃ£o para um registrador)
# mfhi : Move from HI (Move o resto da divisÃ£o para um registrador)
# syscall : Chamada ao sistema operacional (I/O, arquivos, encerrar)
#
# REGISTRADORES COMUNS:
# $v0, $v1 : Códigos de operação para syscalls e retornos de funções
# $a0-$a3  : Argumentos passados para funções ou syscalls
# $t0-$t9  : Temporários (podem ser sobrescritos livremente)
# $s0-$s7  : Salvos (devem ser preservados ou restaurados)
# $sp      : Stack Pointer (Ponteiro da pilha)
# $ra      : Return Address (Guarda endereço de retorno do jal)
# =============================================================================

.data
# --- Configurações do Jogo ---
velocidade:     .word 60
cobra_tamanho:  .word 3
direcao:        .word 2                   # 1=Cima, 2=Dir, 3=Baixo, 4=Esq
cobra_col:      .word 32, 31, 30          # Posições X iniciais da cabeça e corpo
                .space 4080               # Reserva espaço para o resto crescer (1020 * 4 bytes)
                
cobra_lin:      .word 32, 32, 32          # Posições Y iniciais da cabeça e corpo
                .space 4080               # Reserva espaço para o resto crescer (1020 * 4 bytes)
maca_col:       .word 40
maca_lin:       .word 32

# --- Integração Web ---
arquivo_score:  .asciiz "score.bin"
buffer_score:   .word 0                  

# --- Mensagens Terminal ---
msg_gameover:   .asciiz "Game Over! Pontuacao: "
newline:        .asciiz "\n"

# --- Tabela Display 7 Segmentos (0 a 9) ---
# Máscaras de bits para acender LEDs dos números
seg_table:      .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F

.text
.globl main

main:
# =============================================================================
# TELA INICIAL (Espera tecla ESPAÇO)
# =============================================================================
tela_espera:
    li   $t1, 0xFFFF0000       # Endereço de controle do teclado
    lw   $t0, 0($t1)           # Lê Ready Bit
    andi $t0, $t0, 1           
    beq  $t0, $zero, tela_espera # Polling: Aguarda tecla ser pressionada

    li   $t1, 0xFFFF0004       # Endereço de dados do teclado
    lw   $t2, 0($t1)           # Lê ASCII da tecla
    li   $t3, 32               # ASCII da tecla ESPAÇO
    bne  $t2, $t3, tela_espera   # Ignora se não for ESPAÇO

# =============================================================================
# LOOP PRINCIPAL
# =============================================================================
game_loop:
    # 1. Controlar Velocidade (Delay)
    li   $v0, 32
    lw   $a0, velocidade
    syscall

    # 2. Ler Input do Teclado
    jal  ler_teclado

    # 3. Atualizar Estado Lògico
    jal  atualizar_posicao
    jal  verificar_colisao

    # 4. Renderizar Gráficos (Frame Buffer)
    jal  limpar_tela
    jal  desenhar_maca
    jal  desenhar_cobra

    # 5. Atualizar Hardware Externo
    jal  atualizar_display

    j    game_loop

# =============================================================================
# LEITURA DE TECLADO E INTERRUPÇÃO SÌNCRONA (PAUSA)
# =============================================================================
ler_teclado:
    li   $t1, 0xFFFF0000       
    lw   $t0, 0($t1)           
    andi $t0, $t0, 1           
    beq  $t0, $zero, fim_teclado 

    li   $t1, 0xFFFF0004       
    lw   $t2, 0($t1)           # Guarda ASCII pressionado em $t2

verificar_p:
    li   $t3, 112              # 'p'
    li   $t4, 80               # 'P'
    beq  $t2, $t3, rotina_pausa
    beq  $t2, $t4, rotina_pausa

processar_wasd:
    li   $t3, 119              # 'w'
    beq  $t2, $t3, set_cima
    li   $t3, 115              # 's'
    beq  $t2, $t3, set_baixo
    li   $t3, 97               # 'a'
    beq  $t2, $t3, set_esq
    li   $t3, 100              # 'd'
    beq  $t2, $t3, set_dir
    j    fim_teclado

set_cima:   
    li $t4, 1
    sw $t4, direcao
    j fim_teclado

set_dir:    
    li $t4, 2
    sw $t4, direcao
    j fim_teclado

set_baixo:  
    li $t4, 3
    sw $t4, direcao
    j fim_teclado

set_esq:    
    li $t4, 4
    sw $t4, direcao
    j fim_teclado
    
rotina_pausa:
    li   $t1, 0xFFFF0000       
    lw   $t0, 0($t1)           
    andi $t0, $t0, 1           
    beq  $t0, $zero, rotina_pausa  # Congela a execução (Laço de bloqueio)

    li   $t1, 0xFFFF0004       
    lw   $t2, 0($t1)           
    li   $t3, 112
    li   $t4, 80
    beq  $t2, $t3, fim_teclado     # Despausa se for 'P'
    beq  $t2, $t4, fim_teclado
    j    rotina_pausa

fim_teclado:
    jr   $ra

# =============================================================================
# LÓGICA DE MOVIMENTO E COLISÃO
# =============================================================================
atualizar_posicao:
    # Desloca corpo da cobra copiando posição do nó da frente (de trás pra frente)
    lw   $t0, cobra_tamanho
    addi $t0, $t0, -1
loop_corpo:
    blez $t0, move_cabeca
    
    sll  $t1, $t0, 2
    addi $t2, $t1, -4          # Calcula índice da posição anterior
    
    la   $t3, cobra_col
    add  $t4, $t3, $t2
    lw   $t5, 0($t4)           # Pega X anterior
    add  $t4, $t3, $t1
    sw   $t5, 0($t4)           # Move X para atual
    
    la   $t3, cobra_lin
    add  $t4, $t3, $t2
    lw   $t5, 0($t4)           # Pega Y anterior
    add  $t4, $t3, $t1
    sw   $t5, 0($t4)           # Move Y para atual
    
    addi $t0, $t0, -1
    j    loop_corpo

move_cabeca:
    lw   $t0, direcao
    lw   $t1, cobra_col
    lw   $t2, cobra_lin

    li   $t3, 1
    beq  $t0, $t3, sobe
    
    li   $t3, 2
    beq  $t0, $t3, direita
    
    li   $t3, 3
    beq  $t0, $t3, desce
    
    li   $t3, 4
    beq  $t0, $t3, esquerda

sobe:     
    addi $t2, $t2, -1
    j salva_cabeca

direita:  
    addi $t1, $t1, 1
    j salva_cabeca

desce:    
    addi $t2, $t2, 1
    j salva_cabeca

esquerda: 
    addi $t1, $t1, -1

salva_cabeca:
    sw   $t1, cobra_col
    sw   $t2, cobra_lin
    jr   $ra

verificar_colisao:
    # Colisão com bordas da Tela (Matriz 64x64)
    lw   $t1, cobra_col
    lw   $t2, cobra_lin
    bltz $t1, game_over
    bge  $t1, 64, game_over
    bltz $t2, game_over
    bge  $t2, 64, game_over

    # Comer maçã
    lw   $t3, maca_col
    lw   $t4, maca_lin
    bne  $t1, $t3, colisao_fim
    bne  $t2, $t4, colisao_fim

    # Aumenta tamanho da cobra
    lw   $t5, cobra_tamanho
    addi $t5, $t5, 1
    sw   $t5, cobra_tamanho

    # Gera nova maça (Syscall RNG - Pseudo Aleatório)
    li   $v0, 42
    li   $a1, 62               # Limite máx 62
    syscall
    addi $a0, $a0, 1           # Ajusta para não nascer na borda 0
    sw   $a0, maca_col
    syscall
    addi $a0, $a0, 1
    sw   $a0, maca_lin

colisao_fim:
    jr   $ra

# =============================================================================
# MOTOR GRÁFICO (BITMAP DISPLAY 64x64)
# =============================================================================
limpar_tela:
    li   $t0, 0x10040000
    li   $t1, 0x10044000       # Limite: 64x64 * 4 bytes = 16384 bytes
    li   $t2, 0x000000         # Cor Preta
loop_limpa:
    sw   $t2, 0($t0)
    addi $t0, $t0, 4
    blt  $t0, $t1, loop_limpa
    jr   $ra

desenhar_maca:
    lw   $a0, maca_col
    lw   $a1, maca_lin
    li   $a2, 0x0000FF         # Cor Azul
    jal  escrever_pixel
    jr   $ra

desenhar_cobra:
    lw   $t4, cobra_tamanho
    li   $t5, 0
loop_desenha:
    bge  $t5, $t4, fim_desenha
    
    sll  $t6, $t5, 2
    la   $t7, cobra_col
    add  $t7, $t7, $t6
    lw   $a0, 0($t7)
    
    la   $t7, cobra_lin
    add  $t7, $t7, $t6
    lw   $a1, 0($t7)
    
    li   $a2, 0x00FF00         # Cor Verde
    
    # Salva o contexto na pilha antes do jal
    addi $sp, $sp, -12
    sw   $t4, 0($sp)
    sw   $t5, 4($sp)
    sw   $ra, 8($sp)
    
    jal  escrever_pixel
    
    # Restaura contexto da pilha
    lw   $t4, 0($sp)
    lw   $t5, 4($sp)
    lw   $ra, 8($sp)
    addi $sp, $sp, 12
    
    addi $t5, $t5, 1
    j    loop_desenha
fim_desenha:
    jr   $ra

escrever_pixel:
    # Otimização ULA: Endereço = Base + [(Y * 64) + X] * 4
    sll  $t8, $a1, 6       # Desloca Y 6 bits (Multiplica Y por 64)
    add  $t8, $t8, $a0     # Soma X
    sll  $t8, $t8, 2       # Desloca 2 bits (Multiplica total por 4 bytes)
    li   $t9, 0x10040000   # Endereço Base da VRAM
    add  $t8, $t8, $t9     
    sw   $a2, 0($t8)       # Grava cor no Frame Buffer
    jr   $ra

# =============================================================================
# HARDWARE DE SAÍDA: DISPLAY 7 SEGMENTOS
# =============================================================================
atualizar_display:
    lw   $t0, cobra_tamanho
    addi $t0, $t0, -3          # Calcula Pontuação Real
    
    li   $t1, 10
    div  $t0, $t1              # Score / 10
    mflo $t2                   # Extrai Quociente (Dezenas)
    mfhi $t3                   # Extrai Resto (Unidades)
    
    la   $t4, seg_table
    
    # Acende Display das Dezenas
    add  $t5, $t4, $t2
    lb   $t6, 0($t5)
    li   $t7, 0xFFFF0011
    sb   $t6, 0($t7)
    
    # Acende Display das Unidades
    add  $t5, $t4, $t3
    lb   $t6, 0($t5)
    li   $t7, 0xFFFF0010
    sb   $t6, 0($t7)
    
    jr   $ra

# =============================================================================
# GAME OVER & EXPORTAÇÃO WEB (Middleware via Syscalls)
# =============================================================================
game_over:
    lw   $t0, cobra_tamanho
    li   $t1, 0

    # 1. Guarda Score na Memôria RAM
    lw   $t2, cobra_tamanho
    addi $t2, $t2, -3           
    sw   $t2, buffer_score

    # 2. Syscall 13: Abre arquivo score.bin
    li   $v0, 13                  
    la   $a0, arquivo_score       
    li   $a1, 1                   # Modo Write-only
    li   $a2, 0                   
    syscall
    move $s0, $v0                 # Salva descritor de arquivo (FD)

    # 3. Syscall 15: Escreve no arquivo (4 bytes Little-Endian nativo)
    li   $v0, 15                  
    move $a0, $s0               
    la   $a1, buffer_score        
    li   $a2, 4                   
    syscall

    # 4. Syscall 16: Fecha arquivo (Gera pulso de atualizaÃ§Ã£o pro JS via Live Server)
    li   $v0, 16                  
    move $a0, $s0
    syscall

go_pinta:
    # Animação de Morte: Pinta cobra de vermelho
    bge  $t1, $t0, go_toca_som

    la   $t2, cobra_col
    sll  $t3, $t1, 2
    add  $t2, $t2, $t3
    lw   $a0, 0($t2)

    la   $t2, cobra_lin
    add  $t2, $t2, $t3
    lw   $a1, 0($t2)

    li   $a2, 0xff0000          # Vermelho
    jal  escrever_pixel

    addi $t1, $t1, 1
    j    go_pinta

go_toca_som:
    # Aciona Buzzer/Som de Game Over
    li   $v0, 33        
    li   $a0, 45        
    li   $a1, 800       
    li   $a2, 0         
    li   $a3, 120       
    syscall

go_pausa:
    # Pausa final antes de encerrar
    li   $v0, 32
    lw   $a0, velocidade   
    syscall

    # Imprime Status no Terminal do MARS
    li   $v0, 4
    la   $a0, msg_gameover
    syscall

    lw   $a0, cobra_tamanho
    addi $a0, $a0, -3
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

    # Encerra o Programa (Syscall 10)
    li   $v0, 10
    syscall
