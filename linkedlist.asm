# # # # # # # # # # # # # # # # # # # # # # # # # 
# UFFS - Universidade Federal da Fronteira Sul
# Ciencia da Computacao
# Organizacao de Computadores - 2024.1
# Luciano Lores Caimi
# Alunos:
#   Debora Rebelatto - 1721101034
#   Jonathan Gotz Correa - 2121101052
# # # # # # # # # # # # # # # # # # # # # # # # #

.data
	# Menu
	menu_text: 		 		.string "\nMenu:\n0. Insere Inteiro\n1. Remove Por Indice\n2. Remove Por Valor\n3. Imprime Lista\n4. Estatisticas\n5. Sair do programa\n\nInsira sua escolha: "
	
	# Messages:
	msg_not_implemented: 	.string "\nNot implemented yet!\n"
	msg_invalid_option: 	.string "\nOpcao Invalida\n"
	msg_insert_new_value: 	.string "\nDigite um novo valor para inserir na lista:\n"
	msg_remove_by_index: 	.string "\nDigite o index do numero a ser removido:\n"
	msg_remove_by_value: 	.string "\nDigite o valor do numero a ser removido:\n"
	msg_num_elements: 		.string "\nQuantidade de elementos na lista: "

	msg_total_added:   		.string "\nTotal de numeros adicionados: "
	msg_biggest_value: 		.string "\nMaior valor da lista: "
	msg_smallest_value:		.string "\nMenor valor da lista: "
	msg_empty_list: 		.string "\nLista vazia\n"
	
	# Jumptable to map menu
    jumptable:
		.word insere_inteiro
        .word remove_indice
        .word remove_valor
        .word imprime_lista
        .word estatistica
        .word exit

	# Pointers to the head of the list and to new node
	list_head: 		.word 0
	new_node: 		.word 0, 0

	# Statistics variables
	listCount:    .word 0	 # Stores the number of items in the list
	totalAdded:   .word 0	 # Total number of items added (including removed ones)
	
	biggestValue: .word 0  			# Initialize to the smallest possible integer
	smallestValue:.word 2147483647  # Initialize to the largest possible integer

.text
initialize_list:
  la t0, list_head
  sw x0, 0(t0)

initialize_statistics:
	la t0, listCount
	sw x0, 0(t0)   			# listCount = 0
	la t0, totalAdded
	sw x0, 0(t0)   			# totalAdded = 0
	la t0, biggestValue
	sw x0, 0(t0)   			# biggestValue = 0
	la t0, smallestValue
	li t1, 2147483647  		# Max int
	sw t1, 0(t0)   			# smallestValue = max int

##################################################################
# menu:
# Displays the menu to the user and reads input
##################################################################
menu:
	li a7, 4             
    la a0, menu_text  
    ecall  

    li a7, 5
	ecall
	
##################################################################
# menu_input_validation:
# Validates if the value is above 0 and not above 5
##################################################################
menu_input_validation:
    li t0, 1
    bltz a0, invalid_menu_option 
    li t0, 6
    bgt a0, t0, invalid_menu_option  

##################################################################
# branch_menu:
# branches the menu according to the jumptable
##################################################################
branch_menu:
    slli 	t0, a0, 2 
    la 		t1, jumptable
    add 	t0, t0, t1
    lw 		t0, 0(t0)
    jalr 	zero, t0, 0

##################################################################
# invalid_menu_option:
# Displays a message in case the option inserted is invalid
##################################################################
invalid_menu_option:
	li a7, 4
    la a0, msg_invalid_option
    ecall
    j menu

##################################################################
# insere_inteiro:
# should insert an integer vaue ordered in the list
# 	and update the statistic values
#
# Parametros:
#	a0 = posicao de memoria do ponteiro para o inicio da lista
#	a1 = valor a ser inserido
# Retorno:
#	a0: sucesso = 1
#		falha 	= -1
#
#	a1: sucesso = 1
#		falha 	= -1
##################################################################
insere_inteiro:
	read_value_insert:
    	li a7, 4
		la a0, msg_insert_new_value
		ecall

		li a7, 5
		ecall
		mv t0, a0

	allocate_mem:
    	li a7, 9
    	li a0, 8 
    	ecall
    	mv s0, a0
	
    	sw t0, 0(s0)

    	la t1, list_head    
    	lw t2, 0(t1) 
    	mv t3, x0         

	insert_loop:
    	beqz t2, insert_at_end 
    	lw a0, 0(t2)       
    	bge t0, a0, continue_search

    	sw t2, 4(s0)  
    	beqz t3, update_head
    	sw s0, 4(t3) 
    	j update_statistics

	continue_search:
		mv t3, t2   
		lw t2, 4(t2) 
		j insert_loop

	insert_at_end:

		sw x0, 4(s0)   
		beqz t3, update_head  
		sw s0, 4(t3)  
		j update_statistics

	update_head:
		sw s0, 0(t1) 

##################################################################
# update_statistics:
##################################################################
update_statistics:
update_list_count:
    la t1, listCount
    lw t2, 0(t1)
    addi t2, t2, 1
    sw t2, 0(t1)

update_total_added:
    la t1, totalAdded
    lw t2, 0(t1)
    addi t2, t2, 1
    sw t2, 0(t1)

update_biggest_value:
    la t1, biggestValue
    lw t2, 0(t1)
    blt t0, t2, skip_biggest_update  
    sw t0, 0(t1)                 

skip_biggest_update:
    la t1, smallestValue
    lw t2, 0(t1)
    bgt t0, t2, skip_smallest_update 
    sw t0, 0(t1)

skip_smallest_update:
    j menu 
    
##################################################################
# remove_indice:
# removes an value from the list through its index
##################################################################
remove_indice:
read_value_indice:
  li a7, 4
    la a0, msg_remove_by_index
    ecall

    li a7, 5
    ecall
    mv t0, a0    # t0 = index

    la t1, list_head
    lw t2, 0(t1)
    beqz t2, imprime_lista 

    beqz t0, removeHead

    # Find the node before the one to remove
    mv t3, t2    
    addi t0, t0, -1 

removeLoop:
    beqz t0, foundNode
    lw t3, 4(t3)
    addi t0, t0, -1
    j removeLoop

foundNode:
    lw t4, 4(t3)
    lw t5, 4(t4)
    sw t5, 4(t3)
    j imprime_lista  

removeHead:
    la t1, list_head
    lw t2, 0(t1) 
    lw t3, 4(t2) 
    sw t3, 0(t1)
    j imprime_lista 

##################################################################
# remove_valor:
##################################################################
remove_valor:
read_input_value:
	li a7, 4
    la a0, msg_remove_by_value
    ecall

    li a7, 5
    ecall
    mv t0, a0

    la t1, list_head
    lw t2, 0(t1) 
    beqz t2, imprime_lista  

    lw a0, 0(t2
    beq a0, t0, remove_head

remove_value_loop:
    lw t3, 4(t2)  			
    beqz t3, imprime_lista  
    lw a0, 0(t3)  		
    beq a0, t0, found_value 

    mv t2, t3     	
    j remove_value_loop

found_value:
    lw t4, 4(t3) 
    sw t4, 4(t2) 
    j imprime_lista    

remove_head:
    la t1, list_head
    lw t2, 0(t1) 
    lw t3, 4(t2) 
    sw t3, 0(t1)
    j imprime_lista 

##################################################################
# imprime_lista
##################################################################
imprime_lista:
	la t1, list_head
	lw t2, 0(t1) 
	mv t3, t2
  
print_loop:
	beqz t3, print_newline

	lw a0, 0(t3) 
	li a7, 1 
	ecall

	li a0, 32  
	li a7, 11
	ecall

	lw t3, 4(t3)  
	j print_loop

##################################################################
# estatistica:
# prints the values to each recorded statistic
##################################################################
estatistica:
print_list_count:
	li a7, 4
	la a0, msg_num_elements
	ecall

	la a0, listCount
	lw a0, 0(a0)  
	li a7, 1
	ecall

print_total_added_items:
    li a7, 4
    la a0, msg_total_added
    ecall

    la t0, totalAdded
    lw a0, 0(t0)
    li a7, 1
    ecall

print_biggest_value:
    li a7, 4
    la a0, msg_biggest_value
    ecall

    la t0, biggestValue
    lw a0, 0(t0)      
    li a7, 1        
    ecall

print_smallest_value:
    li a7, 4
    la a0, msg_smallest_value 
    ecall

    la t0, smallestValue 
    lw a0, 0(t0)
    li a7, 1
    ecall

print_newline:
	li a0, '\n'  
	li a7, 11
	ecall

	j menu
	
##################################################################
# exit:
#		bye
##################################################################
exit:
    li a7, 93
    ecall
