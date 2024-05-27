# # # # # # # # # # # # # # # # # # # # # # # # # 
# UFFS - Universidade Federal da Fronteira Sul
# Ciencia da Computacao
# Organizacao de Computadores -2024.1
# Luciano Lores Caimi
# Aluna: Debora Rebelatto - 1721101034
# # # # # # # # # # # # # # # # # # # # # # # # # 

.data
	menu_text: 		 	.string "\nMenu:\n0. Insere Inteiro\n1. Remove Por Indice\n2. Remove Por Valor\n3. Imprime Lista\n4. Estat�sticas\n5. Sair do programa\n\nInsira sua escolha: "
	not_implemented: 	.string "\nNot implemented yet!\n"
	invalid_option: 	.string "\nInvalid Option\n"
	insert_new_value: 	.string "\nDigite um novo valor para inserir na lista:\n"
	buffer: 			.space 12
    jumptable:
		.word insere_inteiro
        .word remove_indice
        .word remove_valor
        .word imprime_lista
        .word estatistica
        .word exit
	node_struct:
        .word 0
        .word 0
        
    stack_bottom:      
        .word 0
        .space 1024

# a0 = endere�o da string a ser impressa nas chamadas do sistema ecall (para sa�da de texto).
# a1 = endere�o do buffer onde a entrada do usu�rio ser� armazenada (buffer).
# a2 = 
# a7 = 
  
.text
initialize_list:
	la sp, stack_bottom    
	add  s0, zero, zero   # s0 (head) = NULL
	add  s2, zero, zero   # s2 (tail) = NULL
	li   s1, 0            # s1 (tamanho) = 0


# menu:
# Displays the menu to the user
menu:
	li a7, 4             
    la a0, menu_text  
    ecall  

    li a7, 5
	ecall

# menu_input_validation:
# Validates if the value is above 0 and not above 5
menu_input_validation:
    li t0, 1
    bltz a0, invalid_menu_option 
    li t0, 6
    bgt a0, t0, invalid_menu_option  

# branch_menu:
# branches the menu according to the jumptable
branch_menu:
    slli t0, a0, 2 
    la t1, jumptable
    add t0, t0, t1
    lw t0, 0(t0)
    jalr zero, t0, 0

# invalid_menu_option:
# Displays a message in case the option inserted is invalid
invalid_menu_option:
	li a7, 4
    la a0, invalid_option
    ecall
    j menu

# insere_inteiro:
# should insert and integer value
insere_inteiro:
    # Imprime mensagem solicitando a entrada do usu�rio
    li a7, 4
    la a0, insert_new_value
    ecall

    # L� um inteiro da entrada padr�o (a0 = valor lido)
    li a7, 5
    ecall
  
    
# remove_indice:
# removes an value from the list through its index
remove_indice:
    j funtion_not_implemented

# remove_valor:
remove_valor:
    j funtion_not_implemented

imprime_lista:
    j funtion_not_implemented

# estatistica:
estatistica:
    j funtion_not_implemented

# function_not_implemented:
# While we're still working on some stuff
# Sorry for the inconvenience
# Road work ahead
funtion_not_implemented:
	li a7, 4               
    la a0, not_implemented
    ecall
    
    j menu

exit:
    li a7, 93
    ecall
