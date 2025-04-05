.data
    # ============= Messages =============
    space: .asciiz  " "
    new_line: .asciiz  "\n"
    initial_menu_message: .asciiz "Welcome to project1 menu, before we start notice that \n1- every string request max size is 255 bit\n2- file can handle up to 40 floats (more than that will be ignored)\n"
    request_file_path: .asciiz "\nPlease enter the file path, Enter q/Q to quit: "
    requist_fitting_method: .asciiz "\n\nPlease enter the fitting method \nEnter FF for 'first fit' or BF for 'best fit', Enter q/Q to quit: " 
    file_content_message: .asciiz "\nFile read contant: "
    sizes_array_content_message: .asciiz "Splited Array: "
    
    # ============ Constant =================
    .align 2 # default is '2' BTW, but for readability
    size: .space 255 # saving the function content
    fitting_method: .space 3 # two letters + '\n' = 3 bytes
    
    # *************** Main array *******************
    sizes_array: .float 0.0:40
    # *************** Main array *******************
    
    maximum_input: .half 255
    point_1__float_value: .float 0.1
    ten_float_value: .float 10.0
    zero_float_value: .float 0.0
    
    #  ============ FILE PATH =================
    file_path: .space 255
    
    # =============== Errors =================
    file_error_more_than_zero: .asciiz "ERROR, file values should be 0 < X < 1 \n"
    error_file_msg: .asciiz "ERROR, Failed to open the file\n"
    unvalid_fitting_method: .asciiz "\nERROR, The chosen method is unvalid, Please Enter FF, BF or Q/q\n"
    
.text
    .globl main, print_array, print_message, add_null, file_handling, string_to_integer,choose_algorithim,first_fit,best_fit,quit


# ================= Save Registors =================
# $S0: Maximum_input bits (255)
# $S1: File Descriptor
# $S2: Number of bytes read from the file
# $S3: Array Lenght

# ==================== Main Function ==================== 
main:

    la $a1, initial_menu_message
    jal print_message
    
    lh $s0, maximum_input # maximum number of input bits allowed
   
menu:

   # ============ Reading the File ============
    jal file_handling # return success or fail through $v0
    bnez $v0,  menu 
    # ============ // Reading the File ============

    # ============ Create array ============
    la $a1, new_line
    jal print_message
    
    jal read_sizes # (return array length through $v0)
    move $s3, $v0
    # ============ // Create array ============
    
    
    # ============ Print array ============
    la $a1, sizes_array_content_message
    jal print_message
    
    la $t0, sizes_array
    li $a1, 4
    jal print_array
    # ============ // Print array ============
    
    # ============ // Choose Algorithim ============
choose_fitting_method:
    jal choose_algorithim # return 1 if FF, 2 if BF, -1 if nor through $v0
    
    bne $v0, 1, v0_is_not_1 # if 1 then FF
    jal first_fit # go to FF function
    
v0_is_not_1:
    
    bne $v0, 2, v0_is_not_2 # if 2 then BF
    jal best_fit # go to BF function

v0_is_not_2:
    la $a1, unvalid_fitting_method
    jal print_message
    
    j choose_fitting_method
    
    j menu
    # ============ // Choose Algorithim ============
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

# ====================================================================
# ==================== First fit Function ============================
# ====================================================================

first_fit:

   la $a1, sizes_array_content_message # Print this message for debugging, remove it later
   jal print_message
   
   jal quit


# ====================================================================
# ==================== Best fit Function ==================== 
# ====================================================================

best_fit:

   la $a1, file_content_message # Print this message for debugging, remove it later
   jal print_message
   
   jal quit


# ====================================================================
# ==================== Choose Algorithim Function ==================== 
# ====================================================================

choose_algorithim:

   addi $sp, $sp, -4
   sw $ra, 0($sp)

   la $a1, requist_fitting_method # print a message to requist choose FF,BF or Q/q
   jal print_message
   
   # read input String by user (syscall 8)
   # $a0: address of array (to save input by user)
   # $a1: maximum number of chars to read
   la $a0, fitting_method 
   li $a1, 3 # $a1 = maximum_input
   li $v0, 8
   syscall
   
   lb $t0, 0($a0) # First charachter
   beq $t0, 0X51, choose_algorithim_quit
   beq $t0, 0X71, choose_algorithim_quit
   j is_FF

choose_algorithim_quit:
   jal quit

   # =========== Check if equail FF ===========
is_FF:
   lb $t0, 0($a0) # First charachter
   bne $t0, 0x46, is_BF # if $a0[0] != F
   
   lb $t0, 1($a0) # Second charachter (Displacment)
   bne $t0, 0x46, is_BF # if $a0[1] != F
   
   li $t2, 1 # return 1 if FF
   
   j end_choosing_method
   
is_BF:

   lb $t0, 0($a0) # First charachter
   bne $t0, 0x42, not_FF_BF # if $a0[0] != B
   
   lb $t0, 1($a0) # Second charachter (Displacment)
   bne $t0, 0x46, not_FF_BF # if $a0[1] != F
   
   li $t2, 2 # return 2 if BF
   
   j end_choosing_method

not_FF_BF:

   li $t2, -1 # return -1 if neither FF nor BF
   
   # Print a message
   j end_choosing_method

end_choosing_method:

   move $v0, $t2 # the return value

   lw $ra, 0($sp)
   addi $sp, $sp, 4
   
   jr $ra

# ====================================================================
# ==================== File Handle Function ==================== 
# ====================================================================

file_handling:

   addi $sp, $sp, -4
   sw $ra, 0($sp)
   
   la $a1, request_file_path 
   jal print_message

#read input file name by user(syscall 8)
#$a0 : address of array(to save input by user)
#$a1 : maximum number of chars to read
   li $v0, 8 
   la $a0, file_path
   move $a1, $s0 # $s0 = 255
   syscall

#add null to the end of the file path
   la $a1, file_path
   jal add_null

#handle if equal Q | q
   la $a1, file_path
   lb $t4, 0($a1)
   beq $t4, 0x51, quit
   beq $t4, 0x71, quit
   j no_quit # if not equail, SKIP
   
   jal quit

no_quit:
#Open the file(syscall 13)
#$a0 : file_path
#$a1 : Read or Write
#$a2 : Mode(ignore)
    li $v0, 13 # open file syscall
    la $a0, file_path #file_path
    li $a1, 0 # 0: (read only)
    li $a2, 0 # Mode (ignore)
    syscall # open the file
    
    move $s1, $v0 # Save file descriptor (if < 0, then there's error)
    
    bgez $s1, no_error # if no error, skip

#== == == == == = IF error == == == == == =
#ERROR MESSAGE
    la $a1, error_file_msg
    jal print_message
    
    li $v0, -1
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
#== == == == == = IF error == == == == == = 

no_error:

#Read the file(syscall 14)
    li $v0, 14 # Open file syscall
#$a0 : File descriptor
#$a1 : address of array to save file in
#$a2 : maximum number of char to read
    move $a0, $s1 
    la $a1, size
    move $a2, $s0
    syscall 
    
    move $s2, $v0   # number of bytes read

#Print 'size'(syscall 4)
    
    la $a1, file_content_message
    jal print_message
    
    la $a1, size
    jal print_message

#Close file(syscall 16)
    li $v0, 16
    move $a0, $s1
    syscall
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    li $v0, 0
    jr $ra
# ====================================================================
# ==================== READ Sizes Function ==================== 
# ====================================================================
read_sizes: 
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    la $t0, size
#flag for if we are in the integer area or decimal, EX : 0.12(0 : integer area) - (12 : decimal area)
    li $t2, 0 # 0 integer area, 1 decimal area
    
    la $t4, sizes_array
    li $t5, 0 # will be used to count length
    
    
read_sizes_loop:
    lb $t1, 0($t0)
    beqz $t1, end_read_sizes_loop
    beq $t1, 0x2C, comma # the value of ',' in ASCII (file example: 0.12,0.9,0.4)
    beq $t1, 0x2E, point # the value of '.' in ASCII (file example: 0.12,0.9,0.4)
    beq $t1, 0x30, zero_integer_handle # if zero, handle it
    bne $t1, 0x30, non_zero_integer # the value of zero in ASCII (to compare if the user didn't enter a 0.numbers, file example: 0.12,0.9,0.4)
    addi $t0, $t0, 1
    j read_sizes_loop
    
point:
    addi $t0, $t0, 1
    addi $t5, $t5, 1
    li $t2, 1 # area flag
    
    la $t7, point_1__float_value 
    l.s $f0, 0($t7) # load 0.1 initially 
    
    la $t7, zero_float_value 
    l.s $f1, 0($t7) # load 0.0 initially
    l.s $f3, 0($t7)

    la $t7, ten_float_value 
    l.s $f2, 0($t7) # load 10.0 initially
    
    
point_loop: # loop to keep counting decimals after the point .123456789
    lb $t1, 0($t0)
    beqz $t1, end_point_loop # if the next is null
    beq $t1, 0x2C, end_point_loop # if the next is comma
    bgt $t1, 0x39, non_zero_integer # ERROR ( > 9 )
    blt $t1, 0x30, non_zero_integer # ERROR ( < 0 )
#=== convert to string ===
    move $a1, $t1
    jal string_to_integer # (take $a1 as an arguiment, return $v0)
    move $t1, $v0
#=== convert to string ===
    mtc1 $t1, $f3
    cvt.s.w $f3, $f3    # convert from integer to float
    mul.s $f3, $f3, $f0 # $f3 *= 10^-x
    add.s $f1, $f1, $f3 # $f1 += $f3
    div.s $f0, $f0, $f2 # $f0 /= 10.0
    
    addi $t0, $t0, 1
    j point_loop

end_point_loop: 
    
    ceil.w.s $f2, $f1 # translet it into ceiling (to check if zero, if one then it's ok)
    mfc1 $t6, $f2 # move into $t6
    beqz $t6, non_zero_integer # ERROR, End the loop
    
    s.s $f1, 0($t4) # Store $f1 into the sizes array ($f1 is the count of the decimals)
    addi $t4, $t4, 4
    beqz $t1, end_read_sizes_loop
    
comma: # if facing a comma ',' (0.12,0.13)
  
    addi $t0, $t0, 1
    li $t2, 0
    j read_sizes_loop # continue
  
zero_integer_handle: # if facing a '0' (0.plaplapla)

    addi $t0, $t0, 1
    lb $t1, 0($t0)
#if after the zero is not a point or other zero, ERROR(00.222, 0.plapla)
    beq $t1, 0x30, read_sizes_loop
    beq $t1, 0x2E, read_sizes_loop
    j non_zero_integer
   
non_zero_integer:
    
    la $a1, file_error_more_than_zero # if the integer is not zero, ERROR
    jal print_message
    
    jal quit

end_read_sizes_loop:

    move $v0, $t5 # the return address of array length
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

# ====================================================================
# ==================== String To Integer Function ==================== 
# ====================================================================

string_to_integer: # (arguments: String a1, Return: Integer $v0)
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    move $t0, $a1
    subi $t0, $t0, 0x30 # (HEX: 0 = 0X30, 1 = 0X31 etc...)
    move $v0, $t0
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

# ===========================================================
# ==================== ADD NULL Function ==================== 
# ===========================================================
add_null: # File path is stored into $a1
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $t1, 10 # '\n'

# loop until find '\n' or '\0'
add_null_loop: 
    
    lb $t0, 0($a1)
    beq $t0, $t1, end_add_null_loop
    beqz $t0, already_null
    addi $a1, $a1, 1
    j add_null_loop

end_add_null_loop:
    sb $zero, 0($a1)

# Exit the function
already_null:
 
    lw $ra, 0($sp)
    addi $sp, $sp, 4
   
    jr $ra

# ================================================================
# ==================== Print Message Function ==================== 
# ================================================================
 print_message:

    li $v0, 4
    move $a0, $a1
    syscall

    jr $ra
    
quit:

    li $v0, 10
    syscall 
    
# ==============================================================
# ==================== Print ARRAY Function ====================
# ============================================================== 
print_array:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    
    la $t1, space
    
    move $t3, $a1

print_array_loop:
    l.s $f12, 0($t0)
    addi $t0, $t0, 4
    subi $t3, $t3, 1
    
    li $v0, 2
    syscall
    
    move $a0, $t1
    li $v0, 4
    syscall
    
    beqz  $t3, end_print_array_loop
    
    j print_array_loop
    
end_print_array_loop:

    lw $a0, 0($sp)
    addi $sp, $sp, 4
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
