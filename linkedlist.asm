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
	# Errors
	msg_not_implemented: 	.string "\nNot implemented yet!\n"
	msg_invalid_option: 	.string "\nOpcao Invalida\n"
	
	# Info Prompt
	msg_insert_new_value: 	.string "\nDigite um novo valor para inserir na lista:\n"
	msg_remove_by_index: 	.string "\nDigite o index do numero a ser removido:\n"
	msg_remove_by_value: 	.string "\nDigite o valor do numero a ser removido:\n"
	
	# Statistics
	msg_num_elements: 		.string "\nQuantidade de elementos na lista: "
	msg_biggest_value: 		.string "\nMaior valor da lista: "
	msg_smallest_value:		.string "\nMenor valor da lista: "
	msg_total_added:   		.string "\nTotal de numeros adicionados: "
	msg_total_removed:		.string "\nTotal de numeros removidos: "
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
	listCount:    	.word 0	
	totalAdded:   	.word 0
	totalRemoved:	.word 0

	biggestValue: 	.word 0
	smallestValue:	.word 2147483647 

.text
initialize_list:
    la t0, list_head
    sw x0, 0(t0)

initialize_statistics:
    la t0, listCount
	sw x0, 0(t0)   			# listCount = 0
	
	la t0, totalAdded
	sw x0, 0(t0)   			# totalAdded = 0
	
	la t0, totalRemoved
	sw x0, 0(t0)   			# totalRemoved = 0
	
	la t0, biggestValue
	sw x0, 0(t0)   			# biggestValue = 0
	
	la t0, smallestValue
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
#	a1: sucesso = o indice da posicao inserida
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

	malloc:
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
    	j update_insert_statistics

	continue_search:
		mv t3, t2   
		lw t2, 4(t2) 
		j insert_loop

	insert_at_end:
		sw x0, 4(s0)   
		beqz t3, update_head  
		sw s0, 4(t3)  
		j update_insert_statistics

	update_head:
		sw s0, 0(t1) 

##################################################################
# update_insert_statistics:
# When inserting a new value, update the statistics
##################################################################
update_insert_statistics:
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
# removes a value from the list through its index
# Parametros recebidos:  
#   a0: a posicao de memoria do ponteiro para o inicio da lista;  
#   a1: o indice do elemento da lista a ser removido;  
# Retorno da funcao:  
#   sucesso: o valor presente na posicao removida;  
#   falha: -1 caso nao tenha sido possivel remover da lista;  
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
    beqz t2, imprime_lista # List is empty

    mv t3, x0    # t3 will be the previous node pointer

remove_loop:
    beqz t2, not_found # If t2 is zero, we didn't find the node
    beqz t0, found_node # If t0 is zero, we've found the node to remove
    addi t0, t0, -1 # Decrease the index
    mv t3, t2 # Move t3 to current node
    lw t2, 4(t2) # Move to next node
    j remove_loop

found_node:
    lw t4, 4(t2) # Get the next node of the node to be removed
    lw t5, 0(t2) # Get the value of the node to be removed
    beqz t3, update_head_remove_index # If t3 is zero, we are removing the head
    sw t4, 4(t3) # Otherwise, link the previous node to the next node
    j update_remove_statistics

update_head_remove_index:
    sw t4, 0(t1) # Update the head to the next node

not_found:
    j imprime_lista

update_remove_statistics:
    la t1, listCount
    lw t2, 0(t1)
    addi t2, t2, -1
    sw t2, 0(t1)
    
    la t1, totalRemoved
    lw t2, 0(t1)
    addi t2, t2, 1
    sw t2, 0(t1)

    # Check if removed value was biggest or smallest
    la t1, biggestValue
    lw t2, 0(t1)
    beq t5, t2, update_biggest_after_remove_index
    la t1, smallestValue
    lw t2, 0(t1)
    beq t5, t2, update_smallest_after_remove_index

    j menu

update_biggest_after_remove_index:
    la t1, list_head
    lw t2, 0(t1)
    li t3, -2147483648 # Minimum possible value

find_new_biggest_remove_index:
    beqz t2, update_biggest_done_remove_index
    lw t4, 0(t2)
    blt t3, t4, update_biggest_value_remove_index
    lw t2, 4(t2)
    j find_new_biggest_remove_index

update_biggest_value_remove_index:
    mv t3, t4
    lw t2, 4(t2)
    j find_new_biggest_remove_index

update_biggest_done_remove_index:
    la t1, biggestValue
    sw t3, 0(t1)
    j menu

update_smallest_after_remove_index:
	# ...Implementation similar to finding smallest in insert)

##################################################################
# remove_valor:
# Parametros recebidos:  
# a0: a posicao de memoria do ponteiro para o inicio da lista;  
# a1: o valor a ser removido;  
# Retorno da funcao:  
#     em caso de sucesso: o indice do elemento removido;  
#     em caso de falha: -1 caso n�o tenha sido possivel remover da lista;  
# Funcionalidade: a funcao deve retirar o primeiro elemento com o valor informado presente nada lista;  
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

    lw a0, 0(t2)
    beq a0, t0, remove_head_valor

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
    j update_remove_statistics

remove_head_valor:
    la t1, list_head
    lw t2, 0(t1) 
    lw t3, 4(t2) 
    sw t3, 0(t1)
    j update_remove_statistics

##################################################################
# imprime_lista
# Parametros recebidos:  
# a0: a posicao de memoria do ponteiro para o inicio da lista;
# Retorno da funcao: a funcao nao possui retorno  
# Funcionalidade: a funcao deve mostrar na tela todos os elementos presentes na lista;  
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
# Retorno da funcao: a funcao nao possui retorno  
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
    
print_total_removed_items:
    li a7, 4
    la a0, msg_total_removed
    ecall

    la t0, totalRemoved
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
