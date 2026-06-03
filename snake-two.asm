# =============================================================================
# JOGO DA COBRINHA (SNAKE) EM ASSEMBLY MIPS - VERSÃO FINAL (COM PLACAR 7-SEG)
# =============================================================================
#
# CONFIGURAÇÃO DO MARS:
# 1. Tools > Bitmap Display:
#       - Unit: 8x8 | Display: 512x512 | Base address: 0x10040000 (heap)
# 2. Tools > Keyboard and Display MMIO Simulator
# =============================================================================

.data

# Arrays paralelos para o corpo da cobra
cobra_col:     .space 16384     
cobra_lin:     .space 16384     

# Variaveis de estado da cobra
cobra_tamanho: .word 3          
cobra_dir_col: .word 1          
cobra_dir_lin: .word 0          

# Posicao inicial da maca
maca_col:      .word 40
maca_lin:      .word 20

msg_inicio:    .asciiz "=== SNAKE MIPS - Iniciando ===\n"
msg_gameover:  .asciiz "\n=== GAME OVER! ===\nPontuacao Final: "
newline:       .asciiz "\n"

# Dicionário Hexadecimal para o Display de 7 Segmentos (Números de 0 a 9)
display_7seg:  .byte 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F
    
velocidade:    .word 400       # Começa em 400ms

.text
.globl main

# =============================================================================
# FUNCAO: main
# =============================================================================
main:
    # --- TESTE DE SOM INICIAL ---
    li $v0, 31
    li $a0, 60        
    li $a1, 500       
    li $a2, 0         
    li $a3, 127       
    syscall

    li   $v0, 4
    la   $a0, msg_inicio
    syscall

    # Limpar tela do terminal
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
    
    # Inicia o placar zerado (00)
    jal  atualizar_placar

game_loop:
    jal  ler_teclado
    jal  mover_cobra
    jal  verificar_colisao_borda
    jal  verificar_colisao_corpo
    jal  verificar_maca
    jal  redesenhar_cobra

    # Pausa baseada na velocidade atual
    li   $v0, 32
    lw   $a0, velocidade
    syscall

    j    game_loop

# =============================================================================
# FUNCAO: escrever_pixel
# =============================================================================
escrever_pixel:
    sll  $t8, $a1, 6        
    add  $t8, $t8, $a0      
    sll  $t8, $t8, 2        
    li   $t9, 0x10040000    
    add  $t9, $t9, $t8      
    sw   $a2, 0($t9)        
    jr   $ra

# =============================================================================
# FUNCAO: inicializar_cobra
# =============================================================================
inicializar_cobra:
    la   $t0, cobra_col
    la   $t1, cobra_lin

    li   $t2, 32            
    sw   $t2, 0($t0)
    sw   $t2, 0($t1)

    li   $t2, 31
    sw   $t2, 4($t0)
    li   $t2, 32
    sw   $t2, 4($t1)

    li   $t2, 30
    sw   $t2, 8($t0)
    li   $t2, 32
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
    slti $t2, $t1, 63       
    bne  $t2, $zero, df_col

    addi $s0, $s0, 1
    slti $t2, $s0, 63       
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
    li   $a2, 0xAAAAAA      
    jal  escrever_pixel

    move $a0, $t0
    li   $a1, 63            
    li   $a2, 0xAAAAAA      
    jal  escrever_pixel

    addi $t0, $t0, 1
    slti $t2, $t0, 64       
    bne  $t2, $zero, db_h

    li   $t0, 0

db_v:
    li   $a0, 0
    move $a1, $t0
    li   $a2, 0xAAAAAA      
    jal  escrever_pixel

    li   $a0, 63            
    move $a1, $t0
    li   $a2, 0xAAAAAA      
    jal  escrever_pixel

    addi $t0, $t0, 1
    slti $t2, $t0, 64       
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
    li   $t4, 105
    beq  $t1, $t4, lt_cima
    li   $t4, 73
    beq  $t1, $t4, lt_cima
    li   $t4, 56
    beq  $t1, $t4, lt_cima

    li   $t4, 115
    beq  $t1, $t4, lt_baixo
    li   $t4, 83
    beq  $t1, $t4, lt_baixo
    li   $t4, 107
    beq  $t1, $t4, lt_baixo
    li   $t4, 75
    beq  $t1, $t4, lt_baixo
    li   $t4, 50
    beq  $t1, $t4, lt_baixo

    li   $t4, 97
    beq  $t1, $t4, lt_esq
    li   $t4, 65
    beq  $t1, $t4, lt_esq
    li   $t4, 106
    beq  $t1, $t4, lt_esq
    li   $t4, 74
    beq  $t1, $t4, lt_esq
    li   $t4, 52
    beq  $t1, $t4, lt_esq

    li   $t4, 100
    beq  $t1, $t4, lt_dir
    li   $t4, 68
    beq  $t1, $t4, lt_dir
    li   $t4, 108
    beq  $t1, $t4, lt_dir
    li   $t4, 76
    beq  $t1, $t4, lt_dir
    li   $t4, 54
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
    move $t1, $t0           

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
    slti $t2, $t0, 63       
    beq  $t2, $zero, vcb_hit
    slti $t2, $t1, 1
    bne  $t2, $zero, vcb_hit
    slti $t2, $t1, 63       
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

    sll  $t5, $t4, 2      
    la   $t6, cobra_col
    add  $t7, $t6, $t5
    lw   $t8, 0($t7)      
    sw   $t8, 4($t7)      
    
    la   $t6, cobra_lin
    add  $t7, $t6, $t5
    lw   $t8, 0($t7)      
    sw   $t8, 4($t7)      

    # Aumenta o tamanho da cobra
    addi $t4, $t4, 1
    sw   $t4, cobra_tamanho

    # --- ATUALIZA O PLACAR 7 SEGMENTOS ---
    jal  atualizar_placar

    # Aumenta a velocidade
    lw   $t6, velocidade       
    subi $t6, $t6, 50        
    
    bgt  $t6, 150, salva_vel 
    li   $t6, 150              
    
salva_vel:
    sw   $t6, velocidade       
    
    # Toca o som de comer a maçã
    li $v0, 31        
    li $a0, 76        
    li $a1, 150       
    li $a2, 0         
    li $a3, 100       
    syscall

    jal  gerar_maca
    jal  desenhar_maca

vm_fim:
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra

# =============================================================================
# FUNCAO: atualizar_placar (Display 7 Segmentos)
# =============================================================================
atualizar_placar:
    # 1. Calcular a pontuação atual (Tamanho atual - 3 do tamanho inicial)
    lw   $t0, cobra_tamanho
    addi $t0, $t0, -3
    
    # Se a pontuação passar de 99, trava no 99 para não bugar o display
    li   $t1, 99
    ble  $t0, $t1, ap_divide
    move $t0, $t1

ap_divide:
    # 2. Dividir a pontuação por 10 para achar Dezenas e Unidades
    li   $t1, 10
    div  $t0, $t1
    mflo $t2               # $t2 = Quociente (Dezenas)
    mfhi $t3               # $t3 = Resto (Unidades)

    # 3. Buscar os códigos hexadecimais na memória (.data)
    la   $t4, display_7seg   
    
    add  $t5, $t4, $t2      
    lb   $t6, 0($t5)       # $t6 = Código Hex das Dezenas

    add  $t7, $t4, $t3      
    lb   $t8, 0($t7)       # $t8 = Código Hex das Unidades

    # 4. Enviar os códigos elétricos para as portas de Saída (MMIO)
    li   $t9, 0xFFFF0011   # Endereço do display da Esquerda (Dezenas)
    sb   $t6, 0($t9)         

    li   $t9, 0xFFFF0010   # Endereço do display da Direita (Unidades)
    sb   $t8, 0($t9)         

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
    li   $a1, 62            
    syscall
    addi $t8, $a0, 1       

    li   $v0, 42
    li   $a0, 0
    li   $a1, 62            
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
    bge  $t1, $t0, go_toca_som

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

go_toca_som:
    li $v0, 33        
    li $a0, 45        
    li $a1, 800       
    li $a2, 0         
    li $a3, 120       
    syscall

go_pausa:
    li $v0, 32
    lw $a0, velocidade   
    syscall

    li   $v0, 4
    la   $a0, msg_gameover
    syscall

    # Calcula a pontuação final para imprimir no terminal
    lw   $a0, cobra_tamanho
    addi $a0, $a0, -3
    li   $v0, 1
    syscall

    li   $v0, 4
    la   $a0, newline
    syscall

    li   $v0, 10
    syscall
