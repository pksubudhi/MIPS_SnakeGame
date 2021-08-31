########################################################################
# Contact: P K Subudhi
# mailtopksubudhi@gmail.com
# WhatsApp: +91-8895174939
# Website: www.pksubudhi.com

# Tiny Snake Game
#
# Description: The player will play moving snake within 15x15 grid 
# that eats up randomly positioned apple and grow its length until 
# it fails to do so or reaches to maximum length.
#
# Movements could be done through 4 assigned keys in 4 different
# direction North, East, South and West through w, d, s and d 
# respectively.
#
# Project Done in July 2021
# Version 1.0
# Coding Platform: Assembly Language
#
# Author of this program: P K Subudhi
# WhatsApp No: +91-8895174939
# Mail ID: mailtopksubudhi@gmail.com
# Website: www.pksubudhi.com
#########################################################################

	

########################################################################
# Constant definitions.

N_COLS          = 15
N_ROWS          = 15
MAX_SNAKE_LEN   = N_COLS * N_ROWS

EMPTY           = 0
SNAKE_HEAD      = 1
SNAKE_BODY      = 2
APPLE           = 3

NORTH       = 0
EAST        = 1
SOUTH       = 2
WEST        = 3


########################################################################
# .DATA
	.data

# const char symbols[4] = {'.', '#', 'o', '@'};
symbols:
	.byte	'.', '#', 'o', '@'

	.align 2
# int8_t grid[N_ROWS][N_COLS] = { EMPTY };
grid:
	.space	N_ROWS * N_COLS

	.align 2
# int8_t snake_body_row[MAX_SNAKE_LEN] = { EMPTY };
snake_body_row:
	.space	MAX_SNAKE_LEN

	.align 2
# int8_t snake_body_col[MAX_SNAKE_LEN] = { EMPTY };
snake_body_col:
	.space	MAX_SNAKE_LEN

# int snake_body_len = 0;
snake_body_len:
	.word	0

# int snake_growth = 0;
snake_growth:
	.word	0

# int snake_tail = 0;
snake_tail:
	.word	0

# Game over prompt, for your convenience...
main__game_over:
	.asciiz	"Game over! Your score was "


########################################################################
# .TEXT <main>
	.text
main:


main__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

main__body:

	jal init_snake
	jal update_apple
	
main_loop:
	jal print_grid
	
	jal input_direction 	# Call to inpu_directio
	move $a0, $v0			# Getting user direction input
	
	jal update_snake		# Calling snake_update with direction as argument
	move $t0, $v0			# Collecting return boolen value from update snake
	
	beq $t0, 1, main_loop	# Loop when it is true
	
	
	lw 	$t1, snake_body_len	# Calculating Score
	div $t1, $t1, 3
	
	la $a0, main__game_over	#Showing Geme Over Message
	li $v0, 4
	syscall
	
	move $a0, $t1			#Showing Score
	li $v0, 1
	syscall
	
	li $a0, '\n'
	li $v0, 11
	syscall

	
main__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 0
	jr	$ra			# return 0;



########################################################################
# .TEXT <init_snake>
	.text
init_snake:

init_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

init_snake__body:

	
	# This function sets the initial look and position of the snake
	# Initially Snake is placed at row no 7 (Towards East Direction)
	# Initial body of the snake has 4 componets 
	# 1 Head and 3 body part
	
	
	li $a0, 7			# Row No 7
	li $a1, 7			# Col No 7
	li $a2, SNAKE_HEAD	# Symbol Type SNAKE_HEAD
	jal set_snake
	
	li $a0, 7			# Row No 7
	li $a1, 6			# Col No 6
	li $a2, SNAKE_BODY	# Symbol Type SNAKE_BODY
	jal set_snake
	
	li $a0, 7			# Row No 7
	li $a1, 5			# Col No 5
	li $a2, SNAKE_BODY	# Symbol Type SNAKE_BODY
	jal set_snake
	
	li $a0, 7			# Row No 7
	li $a1, 4			# Col No 4
	li $a2, SNAKE_BODY	# Symbol Type SNAKE_BODY
	jal set_snake
	
init_snake__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	jr	$ra			# return;



########################################################################
# .TEXT <update_apple>
	.text
update_apple:


update_apple__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

update_apple__body:

update_apple_loop:	

	li $a0, N_ROWS
	jal rand_value
	move $t2, $v0		#$t1 holds row
	
	
	li $a0, N_COLS
	jal rand_value
	move $t3, $v0		#t2 holds col
	
	li	$t4, N_COLS
	mul	$t4, $t4, $t2		# 15 * i
	add	$t4, $t4, $t3		# (15 * i) + j
	lb	$t5, grid($t4)		# grid[(15 * i) + j]
	
	bne $t5, EMPTY, update_apple_loop	# Continue if the target position is not empty
		
	li $t6, APPLE
	sb $t6, grid($t4)		# Setting Apple at random position in the grid
	

update_apple__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	jr	$ra			# return;



########################################################################
# .TEXT <update_snake>
	.text
update_snake:


update_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

update_snake__body:

	jal get_d_row
	move $t0, $v0			# d_row is collected at $t0
	
	jal get_d_col
	move $t1, $v0			# d_row is collected at $t1
	
	li $t2, 0
	lb $t3, snake_body_row($t2)	# Getting head_row in $t3
	lb $t4, snake_body_col($t2)	# Getting head_col in $t4
	
		
	li	$t2, N_COLS
	mul	$t2, $t2, $t3		# 15 * i
	add	$t2, $t2, $t4		# (15 * i) + j
	
	
	li  $t5, SNAKE_BODY
	sb	$t5, grid($t2)		# grid[(15 * i) + j]
	
	
	add $t0, $t0, $t3		# New head_row in $t0 
	add $t1, $t1, $t4		# New head col in $t1
	
	blt $t0, 0, update_snake_return_false
	bge $t0, N_ROWS, update_snake_return_false
	blt $t1, 0, update_snake_return_false
	bge $t1, N_COLS, update_snake_return_false
	
	
	li	$t2, N_COLS
	mul	$t2, $t2, $t0		# 15 * i
	add	$t2, $t2, $t1		# (15 * i) + j
	lb	$t3, grid($t2)		# grid[(15 * i) + j]
	
	
	beq $t3, APPLE, store_true_apple_flag
	
	li $t8, 0				# Storing apple flag as FALSE in $t2
	j next_update_snake
	
store_true_apple_flag:
	li $t8, 1				# Storing apple flag as TRUE in $t2
	
next_update_snake:
	
	lw $t3, snake_body_len
	addiu $t3, $t3, -1
	sw $t3, snake_tail		# Decrementing snake_tail
	
	move $a0, $t0
	
	move $a1, $t1
	jal move_snake_in_grid	# Calling move snake in  grid function
	
	move $t2, $v0			# Collecting result
	
	beq $t2, 0, update_snake_return_false	
	
	#move $a0, $t0
	#move $a1, $t1
	jal move_snake_in_array	# Calling move snake in array function
	
	beq $t8, 0, update_snake__epilogue	#Checking if apple is true or false
	
	lw $t4, snake_growth
	addi $t4, $t4, 3
	sw $t4, snake_growth	# Increasing the snake_growth by 3
	jal update_apple		# And updating apple
	
update_snake__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 1
	jr	$ra			# return true;
	
update_snake_return_false:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 0
	jr	$ra			# return false;
	
#################################################################
# .TEXT <move_snake_in_grid>
	.text
move_snake_in_grid:


move_snake_in_grid__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

move_snake_in_grid__body:

	
	lw $t0, snake_growth	# Getting snake growth
	
	ble $t0, 0, snake_growth_less_than_zero
	
	lw $t1, snake_tail
	addi $t1, $t1, 1
	sw $t1, snake_tail		# Incrementing snake tail
	
	lw $t1, snake_body_len
	addi $t1, $t1, 1
	sw $t1, snake_body_len	# Incrementing snake body lenth
	
	
	addi $t0, $t0, -1
	sw $t0, snake_growth	#Decrementing Snake Growth
	
	b next_move_snake_in_grid
	
snake_growth_less_than_zero:

	lw $t1, snake_tail
	lb $t2, snake_body_row($t1)	# Getting snake tail co-ordinates
	lb $t3, snake_body_col($t1)
	
	li	$t4, N_COLS
	mul	$t4, $t4, $t2		# 15 * i
	add	$t4, $t4, $t3		# (15 * i) + j
	
	li  $t5, EMPTY			# Setting it to empty
	sb	$t5, grid($t4)		# grid[(15 * i) + j]
	
next_move_snake_in_grid:
	
	li $t0, N_COLS
	mul $t0, $t0, $a0		# 15 * i
	add $t0, $t0, $a1		# (15 * i) + j
	lb $t1, grid($t0)		# Getting snake body part
	
	beq $t1, SNAKE_BODY, move_snake_return_false
	
	li $t0, N_COLS			# 15 * i
	mul $t0, $t0, $a0		# (15 * i) + j
	add $t0, $t0, $a1
	
	li $t2, SNAKE_HEAD
	sb $t2, grid($t0)		# Setting snake head at new position
	
move_snake_in_grid__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 1
	jr	$ra			# return true;
	
move_snake_return_false:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	li	$v0, 0
	jr	$ra			# return true;
########################################################################
# .TEXT <move_snake_in_array>
	.text
move_snake_in_array:


move_snake_in_array__prologue:
	# set up stack frame
	addiu	$sp, $sp, -4
	sw	$ra, ($sp)

move_snake_in_array__body:
	
	lw $t0, snake_tail
	#beq $t0, 0, move_snake_quit_loop
	
	move $s0, $a0
	move $s1, $a1
	
move_snake_loop:

	addi $t1, $t0, -1
	
	lb $a0, snake_body_row($t1)	# Geting co-ordinates of snake body part
	lb $a1, snake_body_col($t1)	# col and row value
	move $a2, $t0
	
	jal set_snake_array			# Calling set snake array function to change in array
	
	addi $t0, $t0, -1
	bge $t0, 1, move_snake_loop	# Looping unitl complete body moved to new position
	
move_snake_quit_loop:
	move $a0, $s0
	move $a1, $s1
	li $a2, 0
	jal set_snake_array			# Setting new head
	
move_snake_in_array__epilogue:
	# tear down stack frame
	lw	$ra, ($sp)
	addiu 	$sp, $sp, 4

	jr	$ra			# return;

	.data

last_direction:
	.word	EAST

rand_seed:
	.word	0

input_direction__invalid_direction:
	.asciiz	"invalid direction: "

input_direction__bonk:
	.asciiz	"bonk! cannot turn around 180 degrees\n"

	.align	2
input_direction__buf:
	.space	2



########################################################################
# .TEXT <set_snake>
	.text
set_snake:

	
set_snake__prologue:
	# set up stack frame
	addiu	$sp, $sp, -12
	sw	$ra, 8($sp)
	sw	$s0, 4($sp)
	sw	$s1,  ($sp)

set_snake__body:
	move	$s0, $a0		# $s0 = row
	move	$s1, $a1		# $s1 = col

	jal	set_snake_grid		# set_snake_grid(row, col, body_piece);

	move	$a0, $s0
	move	$a1, $s1
	lw	$a2, snake_body_len
	jal	set_snake_array		# set_snake_array(row, col, snake_body_len);

	lw	$t0, snake_body_len
	addiu	$t0, $t0, 1
	sw	$t0, snake_body_len	# snake_body_len++;

set_snake__epilogue:
	# tear down stack frame
	lw	$s1,  ($sp)
	lw	$s0, 4($sp)
	lw	$ra, 8($sp)
	addiu 	$sp, $sp, 12

	jr	$ra			# return;


########################################################################
# .TEXT <set_snake_grid>
	.text
set_snake_grid:

	
	li	$t0, N_COLS
	mul	$t0, $t0, $a0		#  15 * row
	add	$t0, $t0, $a1		# (15 * row) + col
	sb	$a2, grid($t0)		# grid[row][col] = body_piece;

	jr	$ra			# return;


########################################################################
# .TEXT <set_snake_array>
	.text
set_snake_array:

	
	sb	$a0, snake_body_row($a2)	# snake_body_row[nth_body_piece] = row;
	sb	$a1, snake_body_col($a2)	# snake_body_col[nth_body_piece] = col;

	jr	$ra				# return;


########################################################################
# .TEXT <print_grid>
	.text
print_grid:


	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# putchar('\n');

	li	$t0, 0			# int i = 0;

print_grid__for_i_cond:
	bge	$t0, N_ROWS, print_grid__for_i_end	# while (i < N_ROWS)

	li	$t1, 0			# int j = 0;

print_grid__for_j_cond:
	bge	$t1, N_COLS, print_grid__for_j_end	# while (j < N_COLS)

	li	$t2, N_COLS
	mul	$t2, $t2, $t0		#                             15 * i
	add	$t2, $t2, $t1		#                            (15 * i) + j
	lb	$t2, grid($t2)		#                       grid[(15 * i) + j]
	lb	$t2, symbols($t2)	# char symbol = symbols[grid[(15 * i) + j]]

	li	$v0, 11			# syscall 11: print_character
	move	$a0, $t2
	syscall				# putchar(symbol);

	addiu	$t1, $t1, 1		# j++;

	j	print_grid__for_j_cond

print_grid__for_j_end:

	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# putchar('\n');

	addiu	$t0, $t0, 1		# i++;

	j	print_grid__for_i_cond

print_grid__for_i_end:
	jr	$ra			# return;


########################################################################
# .TEXT <input_direction>
	.text
input_direction:

	
input_direction__do:
	li	$v0, 8			# syscall 8: read_string
	la	$a0, input_direction__buf
	li	$a1, 2
	syscall				# direction = getchar()

	lb	$t0, input_direction__buf

input_direction__switch:
	beq	$t0, 'w',  input_direction__switch_w	# case 'w':
	beq	$t0, 'a',  input_direction__switch_a	# case 'a':
	beq	$t0, 's',  input_direction__switch_s	# case 's':
	beq	$t0, 'd',  input_direction__switch_d	# case 'd':
	beq	$t0, '\n', input_direction__switch_newline	# case '\n':
	beq	$t0, 0,    input_direction__switch_null	# case '\0':
	beq	$t0, 4,    input_direction__switch_eot	# case '\004':
	j	input_direction__switch_default		# default:

input_direction__switch_w:
	li	$t0, NORTH			# direction = NORTH;
	j	input_direction__switch_post	# break;

input_direction__switch_a:
	li	$t0, WEST			# direction = WEST;
	j	input_direction__switch_post	# break;

input_direction__switch_s:
	li	$t0, SOUTH			# direction = SOUTH;
	j	input_direction__switch_post	# break;

input_direction__switch_d:
	li	$t0, EAST			# direction = EAST;
	j	input_direction__switch_post	# break;

input_direction__switch_newline:
	j	input_direction__do		# continue;

input_direction__switch_null:
input_direction__switch_eot:
	li	$v0, 17			# syscall 17: exit2
	li	$a0, 0
	syscall				# exit(0);

input_direction__switch_default:
	li	$v0, 4			# syscall 4: print_string
	la	$a0, input_direction__invalid_direction
	syscall				# printf("invalid direction: ");

	li	$v0, 11			# syscall 11: print_character
	move	$a0, $t0
	syscall				# printf("%c", direction);

	li	$v0, 11			# syscall 11: print_character
	li	$a0, '\n'
	syscall				# printf("\n");

	j	input_direction__do	# continue;

input_direction__switch_post:
	blt	$t0, 0, input_direction__bonk_branch	# if (0 <= direction ...
	bgt	$t0, 3, input_direction__bonk_branch	# ... && direction <= 3 ...

	lw	$t1, last_direction	#     last_direction
	sub	$t1, $t1, $t0		#     last_direction - direction
	abs	$t1, $t1		# abs(last_direction - direction)
	beq	$t1, 2, input_direction__bonk_branch	# ... && abs(last_direction - direction) != 2)

	sw	$t0, last_direction	# last_direction = direction;

	move	$v0, $t0
	jr	$ra			# return direction;

input_direction__bonk_branch:
	li	$v0, 4			# syscall 4: print_string
	la	$a0, input_direction__bonk
	syscall				# printf("bonk! cannot turn around 180 degrees\n");

input_direction__while:
	j	input_direction__do	# while (true);


########################################################################
# .TEXT <get_d_row>
	.text
get_d_row:


	beq	$a0, SOUTH, get_d_row__south	# if (direction == SOUTH)
	beq	$a0, NORTH, get_d_row__north	# else if (direction == NORTH)
	j	get_d_row__else			# else

get_d_row__south:
	li	$v0, 1
	jr	$ra				# return 1;

get_d_row__north:
	li	$v0, -1
	jr	$ra				# return -1;

get_d_row__else:
	li	$v0, 0
	jr	$ra				# return 0;


########################################################################
# .TEXT <get_d_col>
	.text
get_d_col:


	beq	$a0, EAST, get_d_col__east	# if (direction == EAST)
	beq	$a0, WEST, get_d_col__west	# else if (direction == WEST)
	j	get_d_col__else			# else

get_d_col__east:
	li	$v0, 1
	jr	$ra				# return 1;

get_d_col__west:
	li	$v0, -1
	jr	$ra				# return -1;

get_d_col__else:
	li	$v0, 0
	jr	$ra				# return 0;



########################################################################
# .TEXT <seed_rng>
	.text
seed_rng:


	sw	$a0, rand_seed		# rand_seed = seed;

	jr	$ra			# return;


########################################################################
# .TEXT <rand_value>
	.text
rand_value:


	lw	$t0, rand_seed		#  rand_seed

	li	$t1, 1103515245
	mul	$t0, $t0, $t1		#  rand_seed * 1103515245

	addiu	$t0, $t0, 12345		#  rand_seed * 1103515245 + 12345

	li	$t1, 0x7FFFFFFF
	and	$t0, $t0, $t1		# (rand_seed * 1103515245 + 12345) & 0x7FFFFFFF

	sw	$t0, rand_seed		# rand_seed = (rand_seed * 1103515245 + 12345) & 0x7FFFFFFF;

	rem	$v0, $t0, $a0
	jr	$ra			# return rand_seed % n;

