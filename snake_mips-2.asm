# =============================================================================
# JOGO DA COBRINHA (SNAKE) EM ASSEMBLY MIPS
# =============================================================================
#
# CONFIGURAÇÃO DO MARS - LEIA ANTES DE EXECUTAR:
# -----------------------------------------------
# 1. Tools > Bitmap Display:
#       - Unit Width in Pixels:  8
#       - Unit Height in Pixels: 8
#       - Display Width in Pixels:  256
#       - Display Height in Pixels: 256
#       - Base address for display: 0x10040000 (heap)  <--- ATENÇÃO AQUI!
#    Clique em "Connect to MIPS"
#
# 2. Tools > Keyboard and Display MMIO Simulator
#    Clique em "Connect to MIPS"
#
# 3. F3 (montar) -> F5 (executar)
# =============================================================================

.data

# Arrays paralelos para o corpo da cobra
cobra_col:     .space 3600      # 900 * 4 bytes
cobra_lin:     .space 3600      # 900 * 4 bytes

# Variaveis de estado da cobra
cobra_tamanho: .word 3          # Comprimento atual
cobra_dir_col: .word 1          # Direcao horizontal: +1=direita, -1=esquerda
cobra_dir_lin: .word 0          # Direcao vertical:   +1=baixo,  -1=cima

# Posicao da maca
maca_col:      .word 20
maca_lin:      .word 10

# Mensagens para o console
msg_inicio:    .asciiz "=== SNAKE MIPS - Iniciando ===\n"
msg_gameover:  .asciiz "\n=== GAME OVER! ===\nPontuacao (tamanho): "
newline:       .asciiz "\n"

.text
.globl main

# =============================================================================
# FUNCAO: main
# =============================================================================
main:
    li   $v0, 4
    la   $a0, msg_inicio
    syscall

    # Inicializa semente do gerador aleatorio
    li   $v0, 40
    li   $a0, 0
    li   $a1, 7919
    syscall

    jal  inicializar_cobra
    jal  desenhar_borda
    jal  desenhar_fundo
    jal  gerar_maca
    jal  desenhar_maca
    jal  desenhar_cobra_completa

game_loop:
    jal  ler_teclado
    jal  mover_cobra
    jal  verificar_colisao_borda
    jal  verificar_colisao_corpo
    jal  verificar_maca
    jal  redesenhar_cobra

    # Controle velocidade do jogo (80ms)
    li   $v0, 32
    li   $a0, 80
    syscall

    j    game_loop

# =============================================================================
# FUNCAO: escrever_pixel
# =============================================================================
escrever_pixel:
    sll  $t8, $a1, 5        
    add  $t8, $t8, $a0      
    sll  $t8, $t8, 2        
    li   $t9, 0x10040000    # <--- CORRIGIDO PARA USAR O HEAP
    add  $t9, $t9, $t8      
    sw   $a2, 0($t9)        
    jr   $ra

# =============================================================================
# FUNCAO: inicializar_cobra
# =============================================================================
inicializar_cobra:
    la   $t0, cobra_col
    la   $t1, cobra_lin

    li   $t2, 16
    sw   $t2, 0($t0)
    sw   $t2, 0($t1)

    li   $t2, 15
    sw   $t2, 4($t0)
    li   $t2, 16
    sw   $t2, 4($t1)

    li   $t2, 14
    sw   $t2, 8($t0)
    li   $t2, 16
    sw   $t2, 8($t1)

    li   $t2, 1
    sw   $t2, cobra_dir_col
    li   $t2, 0
    sw   $t2, cobra_dir_lin
    jr   $ra

# =============================================================================
# FUNCAO: desenhar_fundo
# =============================================================================
desenhar_fundo:
    addi $sp, $sp, -8
    sw   $ra, 4($sp)
    sw   $s0, 0($sp)

    li   $s0, 1             

df_lin:
    li   $t1, 1             

df_col:
    move $a0, $t1
    move $a1, $s0
    li   $a2, 0x1a1a2e      
    jal  escrever_pixel

    addi $t1, $t1, 1
    slti $t2, $t1, 31
    bne  $t2, $zero, df_col

    addi $s0, $s0, 1
    slti $t2, $s0, 31
    bne  $t2, $zero, df_lin

    lw   $s0, 0($sp)
    lw   $ra, 4($sp)
    addi $sp, $sp, 8
    jr   $ra

# =============================================================================
# FUNCAO: desenhar_borda
# =============================================================================
desenhar_borda:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li   $t0, 0

db_h:
    move $a0, $t0
    li   $a1, 0
    li   $a2, 0x16213e
    jal  escrever_pixel

    move $a0, $t0
    li   $a1, 31
    li   $a2, 0x16213e
    jal  escrever_pixel

    addi $t0, $t0, 1
    slti $t2, $t0, 32
    bne  $t2, $zero, db_h

    li   $t0, 0

db_v:
    li   $a0, 0
    move $a1, $t0
    li   $a2, 0x16213e
    jal  escrever_pixel

    li   $a0, 31
    move $a1, $t0
    li   $a2, 0x16213e
    jal  escrever_pixel

    addi $t0, $t0, 1
    slti $t2, $t0, 32
    bne  $t2, $zero, db_v

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# =============================================================================
# FUNCAO: ler_teclado
# =============================================================================
ler_teclado:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    li   $t0, 0xFFFF0000
    lw   $t0, 0($t0)
    andi $t0, $t0, 1
    beq  $t0, $zero, lt_fim

    li   $t1, 0xFFFF0004
    lw   $t1, 0($t1)

    lw   $t2, cobra_dir_col 
    lw   $t3, cobra_dir_lin 

    li   $t4, 119
    beq  $t1, $t4, lt_cima
    li   $t4, 87
    beq  $t1, $t4, lt_cima
    li   $t4, 115
    beq  $t1, $t4, lt_baixo
    li   $t4, 83
    beq  $t1, $t4, lt_baixo
    li   $t4, 97
    beq  $t1, $t4, lt_esq
    li   $t4, 65
    beq  $t1, $t4, lt_esq
    li   $t4, 100
    beq  $t1, $t4, lt_dir
    li   $t4, 68
    beq  $t1, $t4, lt_dir

    j    lt_fim

lt_cima:
    li   $t4, 1
    beq  $t3, $t4, lt_fim   
    li   $t4, 0
    sw   $t4, cobra_dir_col
    li   $t4, -1
    sw   $t4, cobra_dir_lin
    j    lt_fim

lt_baixo:
    li   $t4, -1
    beq  $t3, $t4, lt_fim   
    li   $t4, 0
    sw   $t4, cobra_dir_col
    li   $t4, 1
    sw   $t4, cobra_dir_lin
    j    lt_fim

lt_esq:
    li   $t4, 1
    beq  $t2, $t4, lt_fim   
    li   $t4, -1
    sw   $t4, cobra_dir_col
    li   $t4, 0
    sw   $t4, cobra_dir_lin
    j    lt_fim

lt_dir:
    li   $t4, -1
    beq  $t2, $t4, lt_fim   
    li   $t4, 1
    sw   $t4, cobra_dir_col
    li   $t4, 0
    sw   $t4, cobra_dir_lin

lt_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# =============================================================================
# FUNCAO: mover_cobra
# =============================================================================
mover_cobra:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    lw   $t0, cobra_tamanho
    move $t1, $t0           # <-- CORREÇÃO: Garante que a cauda antiga vai para o índice [tamanho] para ser apagada

mc_loop:
    blez $t1, mc_atualiza_cab

    la   $t2, cobra_col
    sll  $t3, $t1, 2
    add  $t3, $t2, $t3      
    addi $t4, $t1, -1
    sll  $t5, $t4, 2
    add  $t5, $t2, $t5      
    lw   $t4, 0($t5)
    sw   $t4, 0($t3)        

    la   $t2, cobra_lin
    sll  $t3, $t1, 2
    add  $t3, $t2, $t3
    addi $t4, $t1, -1
    sll  $t5, $t4, 2
    add  $t5, $t2, $t5
    lw   $t4, 0($t5)
    sw   $t4, 0($t3)        

    addi $t1, $t1, -1
    j    mc_loop

mc_atualiza_cab:
    lw   $t2, cobra_dir_col
    lw   $t3, cobra_dir_lin

    la   $t4, cobra_col
    lw   $t5, 0($t4)
    add  $t5, $t5, $t2
    sw   $t5, 0($t4)        

    la   $t4, cobra_lin
    lw   $t5, 0($t4)
    add  $t5, $t5, $t3
    sw   $t5, 0($t4)        

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# =============================================================================
# FUNCAO: verificar_colisao_borda
# =============================================================================
verificar_colisao_borda:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    la   $t0, cobra_col
    lw   $t0, 0($t0)
    la   $t1, cobra_lin
    lw   $t1, 0($t1)

    slti $t2, $t0, 1
    bne  $t2, $zero, vcb_hit
    slti $t2, $t0, 31
    beq  $t2, $zero, vcb_hit
    slti $t2, $t1, 1
    bne  $t2, $zero, vcb_hit
    slti $t2, $t1, 31
    beq  $t2, $zero, vcb_hit

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

vcb_hit:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    j    game_over

# =============================================================================
# FUNCAO: verificar_colisao_corpo
# =============================================================================
verificar_colisao_corpo:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    la   $t0, cobra_col
    lw   $t0, 0($t0)
    la   $t1, cobra_lin
    lw   $t1, 0($t1)

    lw   $t2, cobra_tamanho
    li   $t3, 1

vcc_loop:
    bge  $t3, $t2, vcc_ok

    la   $t6, cobra_col
    sll  $t7, $t3, 2
    add  $t6, $t6, $t7
    lw   $t4, 0($t6)

    la   $t6, cobra_lin
    add  $t6, $t6, $t7
    lw   $t5, 0($t6)

    bne  $t0, $t4, vcc_prox
    beq  $t1, $t5, vcc_hit

vcc_prox:
    addi $t3, $t3, 1
    j    vcc_loop

vcc_hit:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    j    game_over

vcc_ok:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# =============================================================================
# FUNCAO: verificar_maca
# =============================================================================
verificar_maca:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    la   $t0, cobra_col
    lw   $t0, 0($t0)
    la   $t1, cobra_lin
    lw   $t1, 0($t1)

    lw   $t2, maca_col
    lw   $t3, maca_lin

    bne  $t0, $t2, vm_fim
    bne  $t1, $t3, vm_fim

    lw   $t4, cobra_tamanho
    addi $t4, $t4, 1
    sw   $t4, cobra_tamanho

    jal  gerar_maca
    jal  desenhar_maca

vm_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# =============================================================================
# FUNCAO: gerar_maca 
# =============================================================================
gerar_maca:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

gm_loop_gera:
    li   $v0, 42
    li   $a0, 0
    li   $a1, 30
    syscall
    addi $t8, $a0, 1        

    li   $v0, 42
    li   $a0, 0
    li   $a1, 30
    syscall
    addi $t9, $a0, 1        

    lw   $t0, cobra_tamanho
    li   $t1, 0             

gm_verifica_corpo:
    bge  $t1, $t0, gm_valida 

    la   $t2, cobra_col
    sll  $t3, $t1, 2
    add  $t2, $t2, $t3
    lw   $t4, 0($t2)        

    la   $t2, cobra_lin
    add  $t2, $t2, $t3
    lw   $t5, 0($t2)        

    bne  $t8, $t4, gm_prox
    beq  $t9, $t5, gm_loop_gera 

gm_prox:
    addi $t1, $t1, 1
    j    gm_verifica_corpo

gm_valida:
    sw   $t8, maca_col
    sw   $t9, maca_lin

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# =============================================================================
# FUNCAO: desenhar_maca
# =============================================================================
desenhar_maca:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    lw   $a0, maca_col
    lw   $a1, maca_lin
    li   $a2, 0xff3355      
    jal  escrever_pixel

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# =============================================================================
# FUNCAO: desenhar_cobra_completa
# =============================================================================
desenhar_cobra_completa:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    lw   $t0, cobra_tamanho
    li   $t1, 0

dcc_loop:
    bge  $t1, $t0, dcc_fim

    la   $t2, cobra_col
    sll  $t3, $t1, 2
    add  $t2, $t2, $t3
    lw   $a0, 0($t2)

    la   $t2, cobra_lin
    add  $t2, $t2, $t3
    lw   $a1, 0($t2)

    bne  $t1, $zero, dcc_corpo
    li   $a2, 0x00ff88
    j    dcc_pinta
dcc_corpo:
    li   $a2, 0x00cc66
dcc_pinta:
    jal  escrever_pixel

    addi $t1, $t1, 1
    j    dcc_loop

dcc_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# =============================================================================
# FUNCAO: redesenhar_cobra
# =============================================================================
redesenhar_cobra:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)

    lw   $t0, cobra_tamanho

    la   $t1, cobra_col
    sll  $t2, $t0, 2
    add  $t1, $t1, $t2
    lw   $a0, 0($t1)

    la   $t1, cobra_lin
    add  $t1, $t1, $t2
    lw   $a1, 0($t1)

    li   $a2, 0x1a1a2e      
    jal  escrever_pixel

    slti $t3, $t0, 2
    bne  $t3, $zero, rc_cab

    la   $t1, cobra_col
    lw   $a0, 4($t1)
    la   $t1, cobra_lin
    lw   $a1, 4($t1)
    li   $a2, 0x00cc66
    jal  escrever_pixel

rc_cab:
    la   $t1, cobra_col
    lw   $a0, 0($t1)
    la   $t1, cobra_lin
    lw   $a1, 0($t1)
    li   $a2, 0x00ff88
    jal  escrever_pixel

    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# =============================================================================
# FUNCAO: game_over
# =============================================================================
game_over:
    lw   $t0, cobra_tamanho
    li   $t1, 0

go_pinta:
    bge  $t1, $t0, go_pausa

    la   $t2, cobra_col
    sll  $t3, $t1, 2
    add  $t2, $t2, $t3
    lw   $a0, 0($t2)

    la   $t2, cobra_lin
    add  $t2, $t2, $t3
    lw   $a1, 0($t2)

    li   $a2, 0xff0000
    jal  escrever_pixel

    addi $t1, $t1, 1
    j    go_pinta

go_pausa:
    li   $v0, 32
    li   $a0, 1000
    syscall

    li   $v0, 4
    la   $a0, msg_gameover
    syscall

    li   $v0, 1
    lw   $a0, cobra_tamanho
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

    li   $v0, 10
    syscall