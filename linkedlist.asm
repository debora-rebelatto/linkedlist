# # # # # # # # # # # # # # # # # # # # # # # # # 
# UFFS - Universidade Federal da Fronteira Sul
# Ciencia da Computacao
# Organizacao de Computadores -2024.1
# Luciano Lores Caimi
# Aluna: Debora Rebelatto - 1721101034
# # # # # # # # # # # # # # # # # # # # # # # # # 

.data
	menu_text: 		 	.string "\nMenu:\n0. Insere Inteiro\n1. Remove Por Indice\n2. Remove Por Valor\n3. Imprime Lista\n4. Estatisticas\n5. Sair do programa\n\nInsira sua escolha: "
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

listHead: .word 0  # Pointer to the head of the list
newNode: .word 0, 0  # Memory for a new node (data and next fields)

# a0 = endereï¿½o da string a ser impressa nas chamadas do sistema ecall (para saida de texto).
# a1 = endereï¿½o do buffer onde a entrada do usuario sera armazenada (buffer).
# a2 = 
# a7 = 

.text
initialize_list:
  la t0, listHead
  sw x0, 0(t0)

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
    la a0, invalid_option
    ecall
    j menu

# insere_inteiro:
# should insert and integer value
insere_inteiro:
read_int: 
    # Imprime mensagem solicitando a entrada do usuï¿½rio
    li a7, 4
    la a0, insert_new_value
    ecall

	li a7, 5  
	ecall
	mv t0, a0  

	#Allocate memory for the new node
	li a7, 9
  li a0, 8 # Size of two words (data and next)
  ecall
  mv s0, a0 # Store the address of the new node in s0

  # Store data in newNode
  sw t0, 0(s0)  
  
  # Get the current head 
  la t2, listHead
  lw t3, 0(t2)  
  # Store current head as next in newNode
  sw t3, 4(s0) 

  # Update listHead to point to the new node
  sw s0, 0(t2)   
  
  j menu

    
# remove_indice:
# removes an value from the list through its index
remove_indice:
read_index:
    li a7, 5
    ecall
    mv t0, a0    # t0 = index

    # Check if the list is empty
    la t1, listHead
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
    la t1, listHead
    lw t2, 0(t1)  # t2 = head node
    lw t3, 4(t2)  # t3 = next node after head
    sw t3, 0(t1)  # Update listHead to point to the next node
    j imprime_lista    # Go back to printList

# remove_valor:
remove_valor:
read_value:
    li a7, 5
    ecall
    mv t0, a0    # t0 = value to remove

    # Check if the list is empty
    la t1, listHead
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
  la t1, listHead
  lw t2, 0(t1)   # Load head into t2
  mv t3, t2      # t3 is the current node
  
printLoop:
  # Check if we've reached the end of the list
  beqz t3, endPrint
  
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

endPrint:
  li a0, '\n'     # Newline after printing the list
  li a7, 11
  ecall
  j menu

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
