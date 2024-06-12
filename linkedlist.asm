# # # # # # # # # # # # # # # # # # # # # # # # # 
# UFFS - Universidade Federal da Fronteira Sul
# Ciencia da Computacao
# Organizacao de Computadores - 2024.1
# Luciano Lores Caimi
# Aluna: Debora Rebelatto - 1721101034
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
	
	biggestValue: .word 0  # Initialize to the smallest possible integer
	smallestValue:.word 2147483647  # Initialize to the largest possible integer
	
.text
initialize_list:
  la t0, list_head
  sw x0, 0(t0)

# Initialize the statistics variables
	la t0, listCount
	sw x0, 0(t0)   # listCount = 0
	la t0, totalAdded
	sw x0, 0(t0)   # totalAdded = 0
	la t0, biggestValue
	sw x0, 0(t0)   # biggestValue = 0
	la t0, smallestValue
	li t1, 2147483647  # Max int
	sw t1, 0(t0)   # smallestValue = max int

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
    slli 	t0, a0, 2 
    la 		t1, jumptable
    add 	t0, t0, t1
    lw 		t0, 0(t0)
    jalr 	zero, t0, 0

# invalid_menu_option:
# Displays a message in case the option inserted is invalid
invalid_menu_option:
	li a7, 4
    la a0, msg_invalid_option
    ecall
    j menu

# insere_inteiro:
# should insert an integer value
# and update the statistic values
insere_inteiro:
    li a7, 4
    la a0, msg_insert_new_value
    ecall

    li a7, 5
    ecall
    mv t0, a0  # t0 holds the value to insert

    # Allocate memory for the new node
    li a7, 9
    li a0, 8  # Size of two words (data and next)
    ecall
    mv s0, a0  # s0 holds the address of the new node

    # Store data in the new node
    sw t0, 0(s0)

    # Find the correct position to insert
    la t1, list_head      # t1 holds the address of list_head
    lw t2, 0(t1)          # t2 holds the head node
    mv t3, x0             # t3 is a temporary pointer to track the previous node (initialize to NULL)

insert_loop:
    beqz t2, insert_at_end  # If the list is empty or we reached the end, insert at the end
    lw a0, 0(t2)            # Load the value of the current node
    bge t0, a0, continue_search  # If the new value is greater or equal, continue searching

    # Insert before the current node
    sw t2, 4(s0)    # Set next of new node to the current node
    beqz t3, update_head   # If inserting at the beginning, update list_head
    sw s0, 4(t3)    # Otherwise, update the next of the previous node
    j update_statistics

continue_search:
    mv t3, t2     # Update previous node pointer
    lw t2, 4(t2)  # Move to the next node
    j insert_loop

insert_at_end:
    # Insert the new node at the end
    sw x0, 4(s0)   # Set next of new node to NULL
    beqz t3, update_head  # If inserting at the beginning, update list_head
    sw s0, 4(t3)   # Otherwise, update the next of the previous node
    j update_statistics

update_head:
    sw s0, 0(t1)  # Update list_head to the new node
    
    
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
    blt t0, t2, skipBiggestUpdate  # Branch if new value is smaller
    sw t0, 0(t1)                    # Otherwise, update biggestValue

    skipBiggestUpdate:

    # Update smallestValue if needed
    la t1, smallestValue
    lw t2, 0(t1)
    bgt t0, t2, skipSmallestUpdate  # Branch if new value is bigger
    sw t0, 0(t1)                    # Otherwise, update smallestValue

    skipSmallestUpdate:
    j menu  # Return to the main menu
    
# remove_indice:
# removes an value from the list through its index
remove_indice:
    li a7, 4
    la a0, msg_remove_by_index
    ecall

    li a7, 5
    ecall
    mv t0, a0    # t0 = index

    # Check if the list is empty
    la t1, list_head
    lw t2, 0(t1)
    beqz t2, imprime_lista  # If empty, go back to printList

    # Handle removal at index 0 (head node)
    beqz t0, removeHead

    # Find the node before the one to remove
    mv t3, t2    # t3 = current node
    addi t0, t0, -1  # Decrement index 
    
removeLoop:
    beqz t0, foundNode
    lw t3, 4(t3) # Move to next node
    addi t0, t0, -1
    j removeLoop

foundNode:
    # t3 is now the node before the one to remove
    lw t4, 4(t3)   # t4 = node to remove
    lw t5, 4(t4)   # t5 = next node after the one to remove
    sw t5, 4(t3)   # Update next of the previous node
    j imprime_lista    # Go back to printList


removeHead:
    # Special case: remove the head node
    la t1, list_head
    lw t2, 0(t1)  # t2 = head node
    lw t3, 4(t2)  # t3 = next node after head
    sw t3, 0(t1)  # Update listHead to point to the next node
    j imprime_lista    # Go back to printList

# remove_valor:
remove_valor:
	li a7, 4
    la a0, msg_remove_by_value
    ecall

    li a7, 5
    ecall
    mv t0, a0    # t0 = value to remove

    # Check if the list is empty
    la t1, list_head
    lw t2, 0(t1)  # t2 = current node (initially head)
    beqz t2, imprime_lista  # If empty, go back to printList

    # Handle removal of the head node if it matches the value
    lw a0, 0(t2)  # Load data of current node
    beq a0, t0, removeHead

    # Find the node before the one to remove

removeValueLoop:
    lw t3, 4(t2)  # t3 = next node
    beqz t3, imprime_lista  # Reached end of list without finding the value
    lw a0, 0(t3)  # Load data of next node
    beq a0, t0, foundValue  # Found the value to remove

    mv t2, t3     # Move to the next node
    j removeValueLoop

foundValue:
    # t2 is the node before the one to remove, t3 is the node to remove
    lw t4, 4(t3)   # t4 = node after the one to remove
    sw t4, 4(t2)   # Update next of the previous node
    j imprime_lista    # Go back to printList

imprime_lista:
 # Print the linked list
	la t1, list_head
	lw t2, 0(t1)   # Load head into t2
	mv t3, t2      # t3 is the current node
  
printLoop:
  # Check if we've reached the end of the list
	beqz t3, print_newline
  
  # Print the data of the current node
	lw a0, 0(t3) 
	li a7, 1      # Print integer system call
	ecall

  # Print a space for separation
	li a0, 32      # ASCII code for space
	li a7, 11     # Print character system call
	ecall

	# Move to the next node
	lw t3, 4(t3)  
	j printLoop

# estatistica:
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

exit:
    li a7, 93
    ecall
