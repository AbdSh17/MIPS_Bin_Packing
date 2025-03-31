.data
    # ============= Messages =============
    space: .asciiz  " "
    new_line: .asciiz  "\n"
    initial_menu_message: .asciiz "Welcome to project1 menu, before we start notice that \n1- every string request max size is 255 bit\n"
    error_file_msg: .asciiz "ERROR, Failed to open the file\n"
    request_file_path: .asciiz "\nPlease enter the file path, Enter q or Q to quit: "
    
    # ============ Constant =================
    size: .space 255
    maximum_input: .half 255
    
    #  ============ FILE PATH =================
    file_path: .space 255
.text
    .globl main, print_array, print_space, print_new_line, print_message, add_null, file_handling


# ================= Save Registors =================
# $S0: Maximum_input bits (255)
# $S1: File Descriptor
# $S2: Number of bytes read from the file
#

# ==================== Main Function ==================== 
main:

    la $a1, initial_menu_message
    jal print_message
    
    lh $s0, maximum_input # maximum number of input bits allowed
   
menu:

# ============ Reading the File ============
    jal file_handling # return success or fail through $v0
    
    bnez $v0,  menu

# ============ Reading the File ============
    
    j menu

end_menu:
    
    li $v0, 10
    syscall


# ==================== // Main Function ==================== 
# ============================================================
# ============================================================
# ============================================================
# ============================================================
# ============================================================
# ============================================================

file_handling:
   
   addi $sp, $sp, -4
   sw $ra, 0($sp)
   
   la $a1, request_file_path 
   jal print_message
  
   # read input file name by user (syscall 8)
   # $a0: address of array (to save input by user)
   # $a1: maximum number of chars to read
   li $v0, 8 
   la $a0, file_path
   move $a1, $s0 # $s0 = 255
   syscall
   
   # add null to the end of the file path
   la $a1, file_path
   jal add_null

    # Open the file (syscall 13)
    # $a0: file_path 
    # $a1: Read or Write 
    # $a2: Mode (ignore)
    li $v0, 13 # open file syscall
    la $a0, file_path #file_path
    li $a1, 0 # 0: (read only)
    li $a2, 0 # Mode (ignore)
    syscall # open the file
    
    move $s1, $v0 # Save file descriptor (if < 0, then there's error)
    
    bgez $s1, no_error # if no error, skip

# =========== IF error =========== 
    # ERROR MESSAGE
    la $a1, error_file_msg
    jal print_message
    
    li $v0, -1
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
# =========== IF error =========== 

no_error:
    
    # Read the file (syscall 14)
    li $v0, 14 # Open file syscall
    # $a0: File descriptor
    # $a1: address of array to save file in
    # $a2: maximum number of char to read
    move $a0, $s1 
    la $a1, size
    move $a2, $s0
    syscall 
    
    move $s2, $v0   # number of bytes read

    # Print 'size' (syscall 4)
    la $a1, size
    jal print_message
    
    # Close file (syscall 16)
    li $v0, 16
    move $a0, $s1
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    li $v0, 0
    jr $ra




# ==================== ADD NULL Function ==================== 
add_null: 
    # File path is stored into $a1
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    
    li $t1, 10
    
add_null_loop: 
    
    lb $t0, 0($a1)
    beq $t0, $t1, end_add_null_loop
    beqz $t0, already_null
    addi $a1, $a1, 1
    j add_null_loop


end_add_null_loop:
    sb $zero, 0($a1)

already_null:
 
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
   
    jr $ra
    
# ==================== Print ARRAY Function ==================== 
print_array:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    
    la $t0, size
    la $t1, space
    
    
print_array_loop:
    lb $a0, 0($t0)
    addi $t0, $t0, 1
    beq $a0, $zero, end_print_array_loop
    
    li $v0, 1
    syscall
    
    move $a0, $t1
    
    li $v0, 4
    syscall
    
    
    j print_array_loop
    
end_print_array_loop:

    lw $a0, 0($sp)
    addi $sp, $sp, 4
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
# ==================== Print SPACE Function ==================== 
print_space:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    
    addi $sp, $sp, -4
    sw $v0, 0($sp)
    
    li $v0, 4
    la $a0, space
    syscall
    
    lw $v0, 0($sp)
    addi $sp, $sp, 4
    
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
 
# ==================== Print NEW LINE Function ==================== 
 print_new_line:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    
    addi $sp, $sp, -4
    sw $v0, 0($sp)
    
    li $v0, 4
    la $a0, new_line
    syscall
    
    lw $v0, 0($sp)
    addi $sp, $sp, 4
    
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
# ==================== Print Message Function ==================== 
 print_message:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    
    addi $sp, $sp, -4
    sw $v0, 0($sp)
    
    li $v0, 4
    move $a0, $a1
    syscall
    
    lw $v0, 0($sp)
    addi $sp, $sp, 4
    
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
