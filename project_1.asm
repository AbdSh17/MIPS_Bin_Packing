.data
    # ============= Messages =============
    space: .asciiz  " "
    new_line: .asciiz  "\n"
    colon: .asciiz  ": "
    initial_menu_message: .asciiz "Welcome to project1 menu, before we start notice that \n1- every string request max size is 255 bit\n2- file can handle up to 40 floats (more than that will be ignored)\n"
    request_file_path: .asciiz "\nPlease enter the file path, Enter q/Q to quit: "
    requist_fitting_method: .asciiz "\n\nPlease enter the fitting method \nEnter FF for 'first fit' or BF for 'best fit', Enter q/Q to quit: " 
    file_content_message: .asciiz "\nFile read contant: "
    sizes_array_content_message: .asciiz "Splited Array: "
    output_file_name:    .asciiz "output.txt"
    bin_msg: .asciiz "Bin "
    set_of_dashes: .asciiz "------------------------"
    set_of_pipes: .asciiz "|||||||"
    minimum_bins_msg: .asciiz "The minimum number of required Bins is:  "
    error_output_file_msg: .asciiz "Can't find the file -output.txt- Please make sure to have it in your directory \n"
    output_file_buffer: .space 1024
    # ============ Constant =================
    .align 2 # default is '2' BTW, but for readability
    size: .space 255 # saving the function content
    fitting_method: .space 3 # two letters + '\n' = 3 bytes
    float_2_string_converting: .space 32
    # integer_2_string
    full_bin_capacity: .float 1.0
    end_of_array: .float -1.0
    One_Point_Half: .float 1.5
    
    maximum_input: .half 255
    point_1__float_value: .float 0.1
    ten_float_value: .float 10.0
    zero_float_value: .float 0.0
    max_float_digit: .float 10000000.0

    
    #  ============ FILE PATH =================
    file_path: .space 255
    
    # =============== Errors =================
    file_error_more_than_zero: .asciiz "ERROR, file values should be 0 < X < 1 \n"
    error_file_msg: .asciiz "ERROR, Failed to open the file\n"
    unvalid_fitting_method: .asciiz "\nERROR, The chosen method is unvalid, Please Enter FF, BF or Q/q\n"

.text
    .globl main, print_array, print_message, add_null, file_handling, get_array_length, string_to_integer,choose_algorithim,first_fit,best_fit,quit
 
# ================== Arrays =========================
#  [ 0.8 , 0.12 , 0.4 , 0.7 ] - Main array 
#  [ 1   ,   2  ,  3  ,   4 ] - Numbered Array
#  [ 1.0 , 1.0  , 1.0 , 1.0 ] - Oned Array
#  [ 0xAA, 0XBB , 0XCC ,0XDD] - Array Of Addresses
#  [   ]  [   ]  [   ] [   ]
#  [   ]  [   ]  [   ] [   ]
#  [   ]  [   ]  [   ] [   ]
#  [   ]  [   ]  [   ] [   ]


#        | FF
#        | FF
#        | FF
#        ⬇ FF

#  [ 0.8 , 0.12 , 0.4 , 0.7 ] - Main array 
#  [ 1   ,   2  ,  3  ,   4 ] - Numbered Array
#  [ 0.08 , 0.6  , 0.3 , 1.0 ] - Oned Array
#  [ 0xAA, 0XBB , 0XCC ,0XDD] - Array Of Addresses
#  [0.8]  [0.4]  [0.7] [   ]
#  [0.12] [   ]  [   ] [   ]
#  [   ]  [   ]  [   ] [   ]
#  [   ]  [   ]  [   ] [   ]

# ================= Save Registors =================
# $S0: Maximum_input bits (255)
# $S1: Array Lenght
#
# $S3: Main Array Address
# $S4: Numbered Array Address
# $S5: Oned Array Address
# $S6: Array Of Adresses Address
#
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
    # ============ // Reading the File ============
    
    # ============ Create array ============
    la $a1, new_line
    jal print_message
    
    jal get_array_length # return array length through $v0
    move $a0, $v0
    move $s1, $v0
    jal read_sizes # takes the array size through $a0
    # ============ // Create array ============
    
    # ============ Print array ============
    la $a1, sizes_array_content_message
    jal print_message
    
    move $t0, $s3 
    move $a1, $s1
    jal print_array
    # ============ // Print array ============
restart_fitting:
    # =========== Prepare bins ===========
    move $a0, $s1
    jal make_numbered_array
    move $s4,$v0
    
    move $a0, $s1
    jal make_oned_array
    move $s5,$v0
    
    move $a0, $s1
    jal make_addresses_array
    move $s6,$v0
    # =========== // Prepare bins ===========
    
    # ============ // Choose Algorithim ============
choose_fitting_method:
    jal choose_algorithim # return 1 if FF, 2 if BF, -1 if nor through $v0
    
    move $a1,$s3
    move $a2,$s5
    move $a3,$s6
    move $a0, $s1
    
    bne $v0, 1, v0_is_not_1 # if 1 then FF
    jal first_fit # go to FF function
    j done_fitting
    
v0_is_not_1:
    bne $v0, 2, v0_is_not_2 # if 2 then BF
    jal best_fit # go to BF function
    j done_fitting
    
v0_is_not_2:
    la $a1, unvalid_fitting_method
    jal print_message
    j choose_fitting_method
    
done_fitting:
    move $a0, $s6 # Array of addresses
    move $a1, $s1 # Array length
    # jal print_fitting
    jal print_fitting_2_file
    # jal print_fitting
    move $a0, $s6 # Array of addresses
    move $a1, $s1 # Array length
    move $a2, $s5 
    
    # j restart_fitting
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
    add $t1, $a0, 1 #num of elements +1
    move $t2,$a1 #address of the array
    li $t3,1 #counter
    
Firstloop: #first loop to go over all the items
    lwc1 $f1,0($t2)
    li $t4,1 #counter for the second loop **Not neceassry maybe delete **
    move $t5,$a2 #contains the 1's array
    move $t6,$a3 #contains the array of arrays
    
Secondloop: #second loop to go over the bins
    lwc1 $f2,0($t5)
    c.lt.s $f1,$f2  #bgt $f2,$f1,greater
    bc1t greater
    
    add $t5,$t5,4
    add $t6,$t6,4
    b Secondloop
    
greater:
    sub.s $f2,$f2,$f1
    swc1 $f2,0($t5)
    move $t7,$a1 #put the value temporily in t7
    lw $t0,0($t6) #put the address of the bin in a1
    move $a1,$t0
    move $t8,$ra #put the contet inside of t8 so we can return to the main fucntion
    jal return_first_empty_cell
    move $a1,$t7 # return the values
    move $ra,$t8
    move $t7,$v0
    swc1 $f1,0($t7) #store the item at the returned address
    
    add $t2,$t2,4 #increment for the loop
    add $t3,$t3,1
    bne $t3,$t1 Firstloop
    
    jr $ra

# ====================================================================
# ==================== Return First Empty Cell =======================
# ====================================================================
return_first_empty_cell:
    move $t9,$a1
    la $t0,end_of_array
    lwc1 $f5,0($t0) # f5 = -1.0
LOOP:
    lwc1 $f4,0($t9)
    c.eq.s $f4,$f5 #beq $f4,$f5,found
    bc1t found
    
    add $t9,$t9,4
    b LOOP
found:
    move $v0,$t9
    jr $ra
    
# ====================================================================
# ==================== Best fit Function =============================
# ====================================================================
best_fit:
    move $t1,$a0 #num of elements 
	la $t2,One_Point_Half
	lwc1 $f6,0($t2) #min number
	move $t2,$a1 #address of the array
	li $t3,0 #counter
	
FirstLoop: #first loop to go over all the items
	lwc1 $f1,0($t2)
	li $t4,0 #counter for the second loop
	move $t5,$a2 #contains the 1's array
	move $t6,$a3 #contains the array of arrays
	mov.s $f0,$f6

SecondLoop: #second loop to go over the bins
	lwc1 $f2,0($t5)

	c.lt.s $f1,$f2  #bgt $f2,$f1,greater
	bc1t Greater
	
Secondloop_continued:
	
	add $t5,$t5,4
	add $t6,$t6,4
	add $t4,$t4,1
	beq $t4,$t1,BF_Loop_Finished
	b SecondLoop
	
Greater:
	c.lt.s $f2,$f0
	bc1t New_Min_Found
	b Secondloop_continued

New_Min_Found:
	mov.s $f0,$f2
	move $t0,$t5 #save the address of 1's the new min
	move $t8,$t6 # save the address of the bin for the new min
	b Secondloop_continued
	
BF_Loop_Finished:
	lwc1 $f2,0($t0)
	sub.s $f2,$f2,$f1
	swc1 $f2,0($t0)
	move $t7,$a1 #put the value temporily in t7
	lw $t0,0($t8) #put the address of the bin in a1
	move $a1,$t0
	move $t6,$ra #put the contet inside of t8 so we can return to the main fucntion
	jal return_first_empty_cell
	move $a1,$t7 # return the values
	move $ra,$t6
	move $t7,$v0
	swc1 $f1,0($t7) #store the item at the returned address
	
	add $t2,$t2,4 #increment for the loop
	add $t3,$t3,1
	bne $t3,$t1 FirstLoop
	
        jr $ra
	
	

# ====================================================================
# ==================== Make Numbered Array Function ==================== 
# ====================================================================
make_numbered_array:
    #-----------------Allocating memory for the Array---------------
    add $t4,$a0,1  #number of elemnts +1 
    sll $a0,$a0,2
    li $v0,9
    syscall
    move $t1,$v0
    #-------------------numbering the array-------------------------
    add $t2,$t1,-4
    li $t3,1  #counter
loop:
    add $t2,$t2,4
    sw $t3,0($t2)
    add $t3,$t3,1
    bne $t3,$t4,loop
    #-------------------move the pointer to the base of the array to v0 to return------------
    move $v0,$t1
    jr $ra

# ====================================================================
# ==================== Make Oned Array Function ==================== 
# ====================================================================
make_oned_array:
    #-----------------Allocating memory for the Array---------------
    add $t4,$a0,1  #number of elemnts +1 
    sll $a0,$a0,2
    li $v0,9
    syscall
    move $t1,$v0
    #--------------Putting 1.0 in each cell of the array----------
    move $t2,$t1
    li $t3,1  #counter
    la $t5,full_bin_capacity
    lwc1 $f1,0($t5)
loop2:
    swc1 $f1,0($t2)
    add $t2,$t2,4
    add $t3,$t3,1
    bne $t3,$t4,loop2
    #-------------------move the pointer to the base of the array to v0 to return------------
    move $v0,$t1
    jr $ra
    
#-------------------End of make oned array---------------------

# ====================================================================
# ==================== Make Adresses Array Function ==================== 
# ====================================================================
make_addresses_array:
    #-----------------------Allocating memory for the Array-------------
    add $t4,$a0,1  #number of elemnts +1 
    sll $a0,$a0,2
    li $v0,9
    syscall
    move $t1,$v0
    move $t2,$t1
    #---------------------Making An array for each cell, and putting the addresses inside thoes cells--------
    li $t3,1 #counter
    la $t5,end_of_array
    lwc1 $f1,0($t5) #f1 = -1.0

First_loop: #for making the pointer array and filling it cells with the addresses of the pointed arrays
    li $v0,9
    syscall
    sw $v0,0($t2)
    move $t7,$v0
    li $t6,1 #counter for 2nd loop

Second_loop: #for filling the pointed arrays with -1.0
    swc1 $f1,0($t7)
    add $t7,$t7,4
    add $t6,$t6,1
    bne $t6,$t4,Second_loop
    
    add $t2,$t2,4
    add $t3,$t3,1
    bne $t3,$t4,First_loop
    
    move $v0,$t1
    jr $ra
    
#-------------------End of make addresses array-----------
    

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
    addi $a0, $a0, 1
    lb $t5, 0($a0)
    bne $t5, 0x0A, is_FF # if the input not just 'q'
    beq $t0, 0X51, quit
    beq $t0, 0X71, quit
    j is_FF

    # =========== Check if equail FF ===========
is_FF:
    addi $a0, $a0, -1
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
    addi $a1, $a1, 1
    lb $t5, 0($a1)
    bne $t5, 0, no_quit # if the input not just 'q'
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

    #=========== IF error =========== 
    #ERROR MESSAGE
    la $a1, error_file_msg
    jal print_message
    
    li $v0, -1
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    #=========== IF error =========== 

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
    
    # la $a1, size
    # jal add_null
    
    li $v0, 0
    jr $ra

# ====================================================================
# ==================== READ Sizes Function ==================== 
# ====================================================================
read_sizes: 
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    li $t0, 4
    mul $a0, $a0, $t0 # (number of numbers * 4 (float))
    li $v0, 9
    syscall
    move $t4, $v0 # address of alocated array
    move $s3, $v0
    
    la $t0, size
    #flag for if we are in the integer area or decimal, EX : 0.12(0 : integer area) - (12 : decimal area)
    li $t2, 0 # 0 integer area, 1 decimal area
    
    li $t5, 0 # will be used to count length
    
read_sizes_loop:
    lb $t1, 0($t0)
    beqz $t1, end_read_sizes_loop
    beq $t1, 0x0A, end_read_sizes_loop # '\n'
    beq $t1, 0x2C, skip # the value of ',' in ASCII (file example: 0.12,0.9,0.4) then skip
    beq $t1, 0x2E, point # the value of '.' in ASCII (file example: 0.12,0.9,0.4)
    beq $t1, 0x30, skip # if zero, handle it
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
    beq $t1, 0x0A, end_point_loop # If '\n'
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
    
skip: # if facing a comma ',' (0.12,0.13) or others need to skip
    addi $t0, $t0, 1
    li $t2, 0
    lb $t1, 0($t0)
    beq $t1, 0x2C, non_zero_integer # if two comma in a row, that's unvalid
    j read_sizes_loop # continue
   
non_zero_integer:
    la $a1, file_error_more_than_zero # if the integer is not zero, ERROR
    jal print_message
    
    j menu

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
# ==================== ARRAY Length Function ====================
# ============================================================== 
get_array_length:
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    la $a0, size
    li $t1, 0

get_array_length_loop:
    lb $t0, 0($a0)
    addi $a0, $a0, 1
    beq $t0, 0, end_get_array_length_loop
    beq $t0, 0x2C, comma
    j get_array_length_loop
    
comma:
    addi $t1, $t1, 1
    j get_array_length_loop
    
end_get_array_length_loop:
    addi $t1, $t1, 1
    move $v0, $t1
    jr $ra

# ==============================================================
# ==================== Print Fitting_2_file Function ===========
# ==============================================================

 # output_file_name:    .asciiz "output.txt"
 # output_file_buffer: space 1024
   
print_fitting_2_file: # $a0: Fitting Array Address - $a1: Array Length - $a2: output file address
   
   addi $sp, $sp, -4
   sw $ra, 0($sp) 
   
   move $t0, $a0 # Fitting Array Address
   move $t1, $a1 # Array Length
   move $t4, $a2 # Output File Address
   
   
   li $t2, -1 # Counter
   li $t6, 0
   
   la $t5, set_of_dashes
   la $t7, output_file_buffer
   la $t9, bin_msg
   
address_array_loop_2_file:
    
    beqz $t6, skip_dashes
    move $a0, $t7
    la $a1, set_of_pipes
    jal conncat_string # conncat dashes
    move $t7, $v0
    
    # ==== print dashes ====
    li $t4, 0x0A # new line ascii
    sb $t4, 0($t7)  # print new line
    addi $t7, $t7, 1
    
    move $a0, $t7
    move $a1, $t5
    jal conncat_string # conncat dashes
    move $t7, $v0
    
    li $t4, 0x0A # new line ascii
    sb $t4, 0($t7)  # print new line
    addi $t7, $t7, 1
    # ==== print dashes ====

skip_dashes:

    addi $t2, $t2, 1
    beq $t2, $t1, end_print_fitting_2_file
    
    # ==== print new line ====
    
    li $t4, 0x0A # new line ascii
    sb $t4, 0($t7)
    addi $t7, $t7, 1
    sb $t4, 0($t7)
    addi $t7, $t7, 1
    
    # ==== print new line ====
    
    # ==== load array address ====
    lw $t3,0($t0)
    addi $t0, $t0, 4
    # ==== load array address ====
    
    # ==== check the first number of the array ====
    lwc1 $f12,0($t3)
    cvt.w.s $f13, $f12
    mfc1    $t6, $f13     
    beq $t6, -1 , end_print_fitting_2_file
    # ==== check the first number of the array ====
    
    # ==== print index ====
    move $a0, $t7
    move $a1, $t9
    jal conncat_string # conncat "bin " 
    move $t7, $v0 
    
    addi $t6, $t2, 0x30 # index to string
    sb $t6, 0($t7)
    addi $t7, $t7, 1
    
    li $t4, 0x3A # colon ascii
    sb $t4, 0($t7) # print colon
    addi $t7, $t7, 1
    # ==== print index ====
    
    # ==== print dashes ====
    li $t4, 0x0A # new line ascii
    sb $t4, 0($t7)  # print new line
    addi $t7, $t7, 1
    
    move $a0, $t7
    move $a1, $t5
    jal conncat_string # conncat dashes
    move $t7, $v0
    
    li $t4, 0x0A # new line ascii
    sb $t4, 0($t7)  # print new line
    addi $t7, $t7, 1
    # ==== print dashes ====

elemnts_array_loop_2_file:  
    
    lwc1 $f12,0($t3)
    
    # ==== check the number if -1 ====
    cvt.w.s $f13, $f12
    mfc1    $t6, $f13     
    beq $t6, -1 , address_array_loop_2_file
    # ==== check the number if -1 ====
    
    move $a0, $t7 # where we start concat
    jal conncat_float
    move $t7, $v0 # where we end concat

    addi $t3,$t3,4

    li $t4, 0x20 # space line ascii
    sb $t4, 0($t7)  # print space
    addi $t7, $t7, 1
    
    j elemnts_array_loop_2_file
    
end_print_fitting_2_file:
    
    move $a0, $t7
    la $a1, minimum_bins_msg
    jal conncat_string # conncat dashes
    move $t7, $v0
    
    addi $t2, $t2, 0x30 # convert index toString
    sb $t2, 0($t7)
    addi $t7, $t7,1
    
    sb $zero, 0($t7)
    addi $t7, $t7, 1
    
    la $a1, output_file_buffer
    jal print_message
    
    #Open the file(syscall 13)
    #$a0 : file_path
    #$a1 : Read or Write
    #$a2 : Mode(ignore)
    la $a0, output_file_name
    li $a1, 1
    li $a2, 1
    li $v0, 13
    syscall
    
    bgez $v0, no_openning_error

    la $a1, error_output_file_msg
    jal print_message

no_openning_error:
    
    # Write to afile (syscall 15)
    #$a0: File descriptor
    #$a1: Address of Buffer
    #$a2: Number of chars to write 
    move $a0, $v0
    la $a1, output_file_buffer
    sub $a2, $t7, $a1 # Lenght of the buffer
    li $v0, 15
    syscall
    
    # Close File (syscall 16)
    #$a0: File descriptor
    li $v0, 16
    syscall

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# ==============================================================
# ==================== Conncat Float Function ==================
# ==============================================================

conncat_float: # $f12: number - $a0: buffer location before - $v0: buffer location after
     
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    
    addi $sp, $sp, -4
    sw $t5, 0($sp)
    
    move $t1, $a0
    
    la $t0, max_float_digit
    l.s $f0, 0($t0) # load 10^7 initially
    
    mul.s $f0, $f0, $f12 # f0 = $f12 * 10^7
    cvt.w.s $f0, $f0 # convert to int
    mfc1    $t0, $f0 # $t0 = int($f12 * 10^7)
    
    # ====== ADD "0." ======
    
    li $t2, 0x30 # '0'
    
    sb $t2, 0($t1)
    addi $t1, $t1, 1
    
    li $t2, 0x2E # .
    sb $t2, 0($t1)
    addi $t1, $t1, 1
    
    # ====== ADD "0." ======
      
    # ====== ADD str(int($f12 * 10^7)) ======
    
    li $t2, 0 # counter to know how much to pop
    li $t4, 0 # flag for if we found a number or still zero
    
push_str_loop:

    div  $t0, $t0, 10 # $t0 = $t0 / 10
    mfhi $t3 # t3 = $t0 % 10
    
    bnez $t4, not_RH_zero
    beqz $t3, push_str_loop
    li $t4, 1
not_RH_zero:
    addi $t3, $t3, 0x30 # convert into string
    
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $t2, $t2, 1
    
    bnez $t0, push_str_loop

pop_str_loop:
    
    beqz $t2, end_pop_str_loop
    
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    
    sb $t3, 0($t1)
    addi $t1, $t1, 1
    
    sub $t2, $t2, 1
    
    j pop_str_loop
end_pop_str_loop:

    # ====== ADD str(int($f12 * 10^7)) ======
   
    move $v0, $t1
    
    lw $t5, 0($sp)
    addi $sp, $sp, 4
    
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    
    lw $t1, 0($sp)
    addi $sp, $sp, 4
     
    lw $t0, 0($sp)
    addi $sp, $sp, 4
     
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

# ==============================================================
# ==================== Conncat String Function =================
# ==============================================================

conncat_string: # a0: old original buffer location - $a1: want to conncat buffer location - $v0: new original buffer location
    
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    
    addi $sp, $sp, -4
    sw $t2, 0($sp)

    move $t0, $a0 # old buffer
    move $t1, $a1 # new buffer
    
conncat_str_loop: 
    
    lb $t2, 0($t1) # load from new buffer
    beqz $t2, end_conncat_str_loop
    sb $t2, 0($t0) # store into new buffer
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    j conncat_str_loop

end_conncat_str_loop:
    
    move $v0, $t0
    
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    
    lw $t0, 0($sp)
    addi $sp, $sp, 4

    lw $a0, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

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
